# frozen_string_literal: true

module Api
  module V1
    class TextsController < BaseController
      def index
        scope = Text.all
        if params[:writing_style_id].present?
          scope = scope.where(writing_style_id: params[:writing_style_id])
        end
        if params[:q].present?
          scope = scope.where('name ILIKE ?', "%#{params[:q].to_s.strip}%")
        end
        scope = scope.order(created_at: :desc)

        render_paginated(scope, serializer: Api::V1::TextSerializer)
      end

      def show
        text = Text.find(params[:id])
        render_data(Api::V1::TextSerializer.render(text))
      end

      def create
        writing_style_id = params[:writing_style_id] || params.dig(:text, :writing_style_id)
        writing_style = WritingStyle.find(writing_style_id)

        text = writing_style.texts.build(text_params)
        text.save!
        render_data(Api::V1::TextSerializer.render(text), status: :created)
      end

      def update
        text = Text.find(params[:id])
        text.update!(text_params)
        render_data(Api::V1::TextSerializer.render(text))
      end

      def destroy
        text = Text.find(params[:id])
        text.destroy!
        render_data({ id: text.id, deleted: true })
      end

      private

      def text_params
        extract_params(:text, :name, :corpus, :writing_style_id)
      end
    end
  end
end
