# frozen_string_literal: true

class ExecuteOperationJob < ApplicationJob
  queue_as :default

  def perform(operation_id)
    operation = Operation.find(operation_id)
    return if operation.succeeded? || operation.running?

    operation.mark_running!(provider_job_id: provider_job_id)

    PaperTrail.request.whodunnit = operation.user_id if operation.user_id.present?

    job_class = operation.job_class.constantize
    resource = operation.resource
    args = build_job_args(job_class, resource, operation.metadata || {})

    job_class.perform_now(*args)

    operation.reload
    operation.mark_succeeded!
  rescue StandardError => e
    reset_resource_flags(resource)
    operation.reload.mark_failed!(e)
    raise e
  end

  private

  def build_job_args(job_class, resource, metadata)
    case job_class.name
    when 'WriteScenesJob'
      [resource&.id || metadata['chapter_id']]
    when 'IterateOnBookPlotJob', 'IterateOnCharacterPromptJob', 'IterateOnLocationPromptJob', 'IterateOnWritingStyleJob'
      [resource, metadata['message']]
    when 'MergeBookPlotsJob', 'MergeCharacterPromptsJob', 'MergeLocationPromptsJob', 'MergeWritingStylesJob'
      version = PaperTrail::Version.find(metadata['version_id'])
      version_to_merge = version.reify
      [resource, version_to_merge]
    when 'RenderSceneJob'
      options = metadata.slice('shot_type', 'style').symbolize_keys
      options.empty? ? [resource] : [resource, options]
    else
      [resource]
    end
  end

  def reset_resource_flags(resource)
    return unless resource

    updates = {}
    updates[:pending] = false if resource.respond_to?(:pending) && resource.pending?
    updates[:rendering] = false if resource.respond_to?(:rendering) && resource.rendering?
    resource.update_columns(updates) if updates.any?
  rescue StandardError => e
    Rails.logger.error("Failed to reset resource flags: #{e.message}")
  end
end
