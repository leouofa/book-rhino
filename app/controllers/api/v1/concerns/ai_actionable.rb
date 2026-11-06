# frozen_string_literal: true

module Api
  module V1
    module Concerns
      module AiActionable
        extend ActiveSupport::Concern

        def enqueue_operation!(resource:, operation_type:, job_class:, metadata: {}, resource_serializer: nil)
          operation = Operation.create!(
            user: current_user,
            resource: resource,
            operation_type: operation_type,
            job_class: job_class.to_s,
            metadata: metadata,
            status: 'queued'
          )

          ExecuteOperationJob.perform_later(operation.id)

          response_payload = {
            operation: Api::V1::OperationSerializer.render(operation)
          }

          if resource_serializer
            response_payload[:resource] = resource_serializer.render(resource)
          end

          render_data(response_payload, status: :accepted)
        end
      end
    end
  end
end
