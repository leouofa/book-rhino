# frozen_string_literal: true

module Api
  module V1
    class RegionsController < BaseController
      def index
        scope = Region.all
        if params[:q].present?
          scope = scope.where('name ILIKE :q OR city ILIKE :q OR country ILIKE :q', q: "%#{params[:q].to_s.strip}%")
        end
        scope = scope.where(country: params[:country]) if params[:country].present?
        scope = scope.order(name: :asc)

        render_paginated(scope, serializer: Api::V1::RegionSerializer)
      end

      def show
        region = Region.find(params[:id])
        render_data(Api::V1::RegionSerializer.render(region))
      end

      def create
        region = Region.new(region_params)
        region.save!
        render_data(Api::V1::RegionSerializer.render(region), status: :created)
      end

      def update
        region = Region.find(params[:id])
        region.update!(region_params)
        render_data(Api::V1::RegionSerializer.render(region))
      end

      def destroy
        region = Region.find(params[:id])
        region.destroy!
        render_data({ id: region.id, deleted: true })
      end

      private

      def region_params
        extract_params(:region, :name, :city, :state, :country, :description)
      end
    end
  end
end
