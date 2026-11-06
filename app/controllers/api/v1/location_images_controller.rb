# frozen_string_literal: true

module Api
  module V1
    class LocationImagesController < BaseController
      def index
        location = Location.find(params[:location_id])
        images = location.location_images.order(created_at: :desc)
        render_paginated(images, serializer: Api::V1::ImageSerializer)
      end

      def show
        image = LocationImage.find(params[:id])
        render_data(Api::V1::ImageSerializer.render(image))
      end

      def create
        location = Location.find(params[:location_id])
        title = params[:title] || params.dig(:location_image, :title)

        created_images = []

        files = Array(params[:images] || params[:image] || params.dig(:location_image, :images) || params.dig(:location_image, :image)).compact_blank
        image_url = params[:image_url] || params.dig(:location_image, :image_url)
        image_base64 = params[:image_base64] || params.dig(:location_image, :image_base64)

        if files.any?
          files.each do |file|
            img_title = title.presence || (file.respond_to?(:original_filename) ? File.basename(file.original_filename, '.*').humanize.titleize : 'Location Image')
            record = location.location_images.build(title: img_title)
            Api::ImageAttacher.attach!(record, file: file)
            record.save!
            created_images << record
          end
        elsif image_url.present?
          img_title = title.presence || 'Location Image'
          record = location.location_images.build(title: img_title)
          Api::ImageAttacher.attach!(record, image_url: image_url)
          record.save!
          created_images << record
        elsif image_base64.present?
          img_title = title.presence || 'Location Image'
          record = location.location_images.build(title: img_title)
          Api::ImageAttacher.attach!(
            record,
            image_base64: image_base64,
            filename: params[:filename] || params.dig(:location_image, :filename),
            content_type: params[:content_type] || params.dig(:location_image, :content_type)
          )
          record.save!
          created_images << record
        else
          raise Api::ImageAttacher::AttachmentError, 'No image file, image_url, or image_base64 provided'
        end

        result = created_images.size == 1 ? created_images.first : created_images
        render_data(Api::V1::ImageSerializer.render(result), status: :created)
      end

      def update
        image = LocationImage.find(params[:id])
        title = params[:title] || params.dig(:location_image, :title)
        image.update!(title: title) if title.present?
        render_data(Api::V1::ImageSerializer.render(image))
      end

      def destroy
        image = LocationImage.find(params[:id])
        image.destroy!
        render_data({ id: image.id, deleted: true })
      end
    end
  end
end
