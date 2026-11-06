# frozen_string_literal: true

module Api
  module V1
    class ImageSerializer < BaseSerializer
      def as_json
        data = {
          id: record.id,
          title: record.title,
          created_at: format_time(record.created_at),
          updated_at: format_time(record.updated_at)
        }

        if record.respond_to?(:character_id) && record.character_id.present?
          data[:character_id] = record.character_id
        elsif record.respond_to?(:location_id) && record.location_id.present?
          data[:location_id] = record.location_id
        end

        if record.image.attached?
          blob = record.image.blob
          url = begin
            Rails.application.routes.url_helpers.rails_blob_url(record.image, only_path: false)
          rescue StandardError
            Rails.application.routes.url_helpers.rails_blob_path(record.image, only_path: true)
          end

          data[:image] = {
            url: url,
            filename: blob.filename.to_s,
            content_type: blob.content_type,
            byte_size: blob.byte_size,
            created_at: format_time(blob.created_at)
          }
        else
          data[:image] = nil
        end

        data
      end
    end
  end
end
