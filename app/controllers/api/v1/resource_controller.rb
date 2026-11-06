# frozen_string_literal: true

module Api
  module V1
    class ResourceController < BaseController
      def index
        scope = model_class.all
        if params[:q].present?
          scope = scope.where('name ILIKE ?', "%#{params[:q].to_s.strip}%")
        end
        scope = scope.order(name: :asc)

        render_paginated(scope, serializer: Api::V1::TaxonomySerializer)
      end

      def show
        record = model_class.find(params[:id])
        render_data(Api::V1::TaxonomySerializer.render(record))
      end

      def create
        record = model_class.new(permitted_params)
        record.save!
        render_data(Api::V1::TaxonomySerializer.render(record), status: :created)
      end

      def update
        record = model_class.find(params[:id])
        record.update!(permitted_params)
        render_data(Api::V1::TaxonomySerializer.render(record))
      end

      def destroy
        record = model_class.find(params[:id])
        record.destroy!
        render_data({ id: record.id, deleted: true })
      end

      private

      def model_class
        raise NotImplementedError
      end

      def permitted_params
        extract_params(model_class.name.underscore.to_sym, *allowed_attributes)
      end

      def allowed_attributes
        model_class.column_names.map(&:to_sym) - %i[id created_at updated_at]
      end
    end
  end
end
