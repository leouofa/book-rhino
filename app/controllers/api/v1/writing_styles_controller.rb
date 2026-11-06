# frozen_string_literal: true

module Api
  module V1
    class WritingStylesController < BaseController
      include Concerns::AiActionable
      include Concerns::VersionableActions

      def index
        scope = WritingStyle.all
        if params[:q].present?
          scope = scope.where('name ILIKE ?', "%#{params[:q].to_s.strip}%")
        end
        scope = scope.order(name: :asc)

        render_paginated(scope, serializer: Api::V1::WritingStyleSerializer)
      end

      def show
        writing_style = WritingStyle.find(params[:id])
        include_texts = ActiveModel::Type::Boolean.new.cast(params[:include_texts])
        render_data(Api::V1::WritingStyleSerializer.render(writing_style, include_texts: include_texts))
      end

      def create
        writing_style = WritingStyle.new(writing_style_params)
        writing_style.save!
        render_data(Api::V1::WritingStyleSerializer.render(writing_style), status: :created)
      end

      def update
        writing_style = WritingStyle.find(params[:id])
        writing_style.update!(writing_style_params)
        render_data(Api::V1::WritingStyleSerializer.render(writing_style))
      end

      def destroy
        writing_style = WritingStyle.find(params[:id])
        writing_style.destroy!
        render_data({ id: writing_style.id, deleted: true })
      end

      def generate_prompt
        writing_style = WritingStyle.find(params[:id])
        writing_style.update(pending: true)

        enqueue_operation!(
          resource: writing_style,
          operation_type: 'generate_prompt',
          job_class: GenerateWritingStyleJob,
          resource_serializer: Api::V1::WritingStyleSerializer
        )
      end

      def iterate
        writing_style = WritingStyle.find(params[:id])
        message = params[:message] || params.dig(:writing_style, :message)
        if message.blank?
          render_error(code: 'bad_request', message: 'Parameter :message is required for iterate', status: :bad_request)
          return
        end

        writing_style.update(pending: true)

        enqueue_operation!(
          resource: writing_style,
          operation_type: 'iterate',
          job_class: IterateOnWritingStyleJob,
          metadata: { 'message' => message },
          resource_serializer: Api::V1::WritingStyleSerializer
        )
      end

      private

      def writing_style_params
        extract_params(:writing_style, :name, :prompt)
      end

      def find_versionable_resource
        WritingStyle.find(params[:writing_style_id] || params[:id])
      end

      def versionable_serializer
        Api::V1::WritingStyleSerializer
      end

      def merge_job_class
        MergeWritingStylesJob
      end
    end
  end
end
