# frozen_string_literal: true

module Api
  module V1
    class LocationsController < BaseController
      include Concerns::AiActionable
      include Concerns::VersionableActions

      def index
        scope = Location.all
        if params[:q].present?
          scope = scope.where('name ILIKE :q OR description ILIKE :q', q: "%#{params[:q].to_s.strip}%")
        end
        scope = scope.where(region_id: params[:region_id]) if params[:region_id].present?
        if params[:book_id].present?
          scope = scope.joins(:books).where(books: { id: params[:book_id] })
        end
        scope = scope.order(name: :asc)

        render_paginated(scope, serializer: Api::V1::LocationSerializer)
      end

      def show
        location = Location.find(params[:id])
        render_data(Api::V1::LocationSerializer.render(location, detailed: true))
      end

      def create
        location = Location.new(location_params)
        location.save!
        render_data(Api::V1::LocationSerializer.render(location, detailed: true), status: :created)
      end

      def update
        location = Location.find(params[:id])
        location.update!(location_params)
        render_data(Api::V1::LocationSerializer.render(location, detailed: true))
      end

      def destroy
        location = Location.find(params[:id])
        location.destroy!
        render_data({ id: location.id, deleted: true })
      end

      def generate_prompt
        location = Location.find(params[:id])
        location.update(pending: true)

        enqueue_operation!(
          resource: location,
          operation_type: 'generate_prompt',
          job_class: GenerateLocationPromptJob,
          resource_serializer: Api::V1::LocationSerializer
        )
      end

      def iterate
        location = Location.find(params[:id])
        message = params[:message] || params.dig(:location, :message)
        if message.blank?
          render_error(code: 'bad_request', message: 'Parameter :message is required for iterate', status: :bad_request)
          return
        end

        location.update(pending: true)

        enqueue_operation!(
          resource: location,
          operation_type: 'iterate',
          job_class: IterateOnLocationPromptJob,
          metadata: { 'message' => message },
          resource_serializer: Api::V1::LocationSerializer
        )
      end

      private

      def location_params
        extract_params(
          :location,
          :name, :region_id, :description, :lighting, :time, :noise_level,
          :comfort, :aesthetics, :accessibility, :personalization, :prompt,
          character_ids: []
        )
      end

      def find_versionable_resource
        Location.find(params[:location_id] || params[:id])
      end

      def versionable_serializer
        Api::V1::LocationSerializer
      end

      def merge_job_class
        MergeLocationPromptsJob
      end
    end
  end
end
