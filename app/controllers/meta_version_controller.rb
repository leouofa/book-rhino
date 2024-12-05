class MetaVersionController < ApplicationController
  before_action :set_meta
  before_action :set_parent
  before_action :set_version, only: %i[revert merge]

  def index
    @versions_with_prompt_changes = @parent.versions.map do |version|
      changes = parse_object_changes(version)
      found = changes.any? { |property, (old_value, _new_value)| property == 'prompt' && old_value }

      next unless found

      {
        id: version.id,
        updated_at: changes['updated_at']&.last,
        old_prompt: parse_version_prompt(changes['prompt']&.first)
      }
    end.compact
  end

  def revert
    version_to_revert = @version.reify
    version_to_revert.pending = false
    version_to_revert.save

    redirect_to redirect_path, notice: "Version reverted successfully."
  end

  def merge
    @parent.update(pending: true)

    version_to_merge = @version.reify
    merge_job.perform_later(@parent, version_to_merge)

    redirect_to redirect_path
  end

  private

  def parent_class
    raise NotImplementedError
  end

  def merge_job
    raise NotImplementedError
  end

  def redirect_path
    send(parent_path, @parent)
  end

  def set_meta
    parent_name = parent_class.name.underscore
    base_path = "#{parent_name}_version"

    @version_header = "Previous #{parent_class.name.underscore.titleize} Versions"
    @parent_path = parent_path
    @revert_path = "revert_#{base_path}_path"
    @merge_path = "merge_#{base_path}_path"
  end

  def parse_version_prompt(prompt)
    prompt
  end

  def set_parent
    @parent = parent_class.find_by!(id: params["#{parent_class.name.underscore}_id"])
  end

  def set_version
    @version = @parent.versions.find_by!(id: params[:id])
  end

  def parse_object_changes(version)
    permitted_classes = [Time, Date, ActiveSupport::TimeWithZone, ActiveSupport::TimeZone]
    YAML.safe_load(version.object_changes, permitted_classes:, aliases: true)
  end
end
