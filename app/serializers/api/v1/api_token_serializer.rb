# frozen_string_literal: true

module Api
  module V1
    class ApiTokenSerializer < BaseSerializer
      def as_json
        data = {
          id: record.id,
          name: record.name,
          token_prefix: record.token_prefix,
          active: record.active?,
          last_used_at: format_time(record.last_used_at),
          expires_at: format_time(record.expires_at),
          revoked_at: format_time(record.revoked_at),
          created_at: format_time(record.created_at),
          updated_at: format_time(record.updated_at)
        }
        data[:token] = record.raw_token if record.raw_token.present?
        data
      end
    end
  end
end
