# frozen_string_literal: true

module Api
  module V1
    class RegionSerializer < BaseSerializer
      def as_json
        {
          id: record.id,
          name: record.name,
          city: record.city,
          state: record.state,
          country: record.country,
          description: record.description,
          locations_count: record.locations.size,
          created_at: format_time(record.created_at),
          updated_at: format_time(record.updated_at)
        }
      end
    end
  end
end
