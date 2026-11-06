# frozen_string_literal: true

module Api
  module V1
    class LocationSerializer < BaseSerializer
      def as_json
        data = {
          id: record.id,
          name: record.name,
          region_id: record.region_id,
          description: record.description,
          lighting: record.lighting,
          time: record.time,
          noise_level: record.noise_level,
          comfort: record.comfort,
          aesthetics: record.aesthetics,
          accessibility: record.accessibility,
          personalization: record.personalization,
          prompt: record.prompt,
          pending: record.pending?,
          created_at: format_time(record.created_at),
          updated_at: format_time(record.updated_at)
        }

        if options[:detailed]
          data[:region] = record.region ? RegionSerializer.render(record.region) : nil
          data[:images] = ImageSerializer.render(record.location_images)
          data[:character_ids] = record.character_ids
          data[:book_ids] = record.book_ids
        else
          data[:region_name] = record.region&.name
          data[:images_count] = record.location_images.size
        end

        data
      end
    end
  end
end
