# frozen_string_literal: true

module Api
  module V1
    class VersionSerializer < BaseSerializer
      def as_json
        changes = parse_changes
        {
          id: record.id,
          event: record.event,
          item_type: record.item_type,
          item_id: record.item_id,
          whodunnit: record.whodunnit,
          created_at: format_time(record.created_at),
          changes: changes
        }
      end

      private

      def parse_changes
        return {} if record.object_changes.blank?

        permitted = [Time, Date, ActiveSupport::TimeWithZone, ActiveSupport::TimeZone]
        YAML.safe_load(record.object_changes, permitted_classes: permitted, aliases: true) || {}
      rescue StandardError => e
        { 'error' => "Could not parse changes: #{e.message}" }
      end
    end
  end
end
