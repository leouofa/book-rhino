# frozen_string_literal: true

module Api
  module V1
    class UserSerializer < BaseSerializer
      def as_json
        {
          id: record.id,
          email: record.email,
          has_access: record.has_access?,
          admin: record.admin?,
          created_at: format_time(record.created_at),
          updated_at: format_time(record.updated_at)
        }
      end
    end
  end
end
