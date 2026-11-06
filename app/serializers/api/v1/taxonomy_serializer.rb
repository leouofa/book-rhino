# frozen_string_literal: true

module Api
  module V1
    class TaxonomySerializer < BaseSerializer
      def as_json
        data = {
          id: record.id,
          name: record.name,
          type: record.class.name.underscore,
          created_at: format_time(record.created_at),
          updated_at: format_time(record.updated_at)
        }

        # Add all model-specific attributes dynamically
        record.attributes.each do |key, value|
          next if %w[id name created_at updated_at].include?(key)

          data[key.to_sym] = value
        end

        data
      end
    end
  end
end
