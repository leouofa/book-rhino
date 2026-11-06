# frozen_string_literal: true

module Api
  module V1
    class OperationSerializer < BaseSerializer
      def as_json
        {
          id: record.id,
          user_id: record.user_id,
          resource_type: record.resource_type,
          resource_id: record.resource_id,
          operation_type: record.operation_type,
          job_class: record.job_class,
          status: record.status,
          metadata: record.metadata,
          error_class: record.error_class,
          error_message: record.error_message,
          started_at: format_time(record.started_at),
          completed_at: format_time(record.completed_at),
          created_at: format_time(record.created_at),
          updated_at: format_time(record.updated_at)
        }
      end
    end
  end
end
