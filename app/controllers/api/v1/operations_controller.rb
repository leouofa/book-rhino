# frozen_string_literal: true

module Api
  module V1
    class OperationsController < BaseController
      def index
        scope = Operation.all
        scope = scope.where(status: params[:status]) if params[:status].present?
        scope = scope.where(resource_type: params[:resource_type]) if params[:resource_type].present?
        scope = scope.where(resource_id: params[:resource_id]) if params[:resource_id].present?
        scope = scope.where(operation_type: params[:operation_type]) if params[:operation_type].present?
        scope = scope.order(created_at: :desc)

        render_paginated(scope, serializer: Api::V1::OperationSerializer)
      end

      def show
        operation = Operation.find(params[:id])
        render_data(Api::V1::OperationSerializer.render(operation))
      end
    end
  end
end
