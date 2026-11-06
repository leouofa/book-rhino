# frozen_string_literal: true

module Api
  module V1
    class BooksController < BaseController
      include Concerns::AiActionable
      include Concerns::VersionableActions

      def index
        scope = Book.all
        if params[:q].present?
          scope = scope.where('title ILIKE :q OR plot ILIKE :q', q: "%#{params[:q].to_s.strip}%")
        end
        scope = scope.where(writing_style_id: params[:writing_style_id]) if params[:writing_style_id].present?
        scope = scope.where(perspective_id: params[:perspective_id]) if params[:perspective_id].present?
        scope = scope.where(narrative_structure_id: params[:narrative_structure_id]) if params[:narrative_structure_id].present?
        scope = scope.where(pending: ActiveModel::Type::Boolean.new.cast(params[:pending])) if params[:pending].present?
        scope = scope.where(rendering: ActiveModel::Type::Boolean.new.cast(params[:rendering])) if params[:rendering].present?
        scope = scope.order(created_at: :desc)

        render_paginated(scope, serializer: Api::V1::BookSerializer)
      end

      def show
        book = Book.find(params[:id])
        render_data(Api::V1::BookSerializer.render(book, detailed: true))
      end

      def create
        book = Book.new(book_params)
        book.save!
        render_data(Api::V1::BookSerializer.render(book, detailed: true), status: :created)
      end

      def update
        book = Book.find(params[:id])
        book.update!(book_params)
        render_data(Api::V1::BookSerializer.render(book, detailed: true))
      end

      def destroy
        book = Book.find(params[:id])
        book.destroy!
        render_data({ id: book.id, deleted: true })
      end

      def manuscript
        book = Book.find(params[:id])
        render_data(Api::V1::BookSerializer.render(book, manuscript: true))
      end

      def generate_prompt
        book = Book.find(params[:id])
        book.update(pending: true)

        enqueue_operation!(
          resource: book,
          operation_type: 'generate_prompt',
          job_class: GenerateBookPlotJob,
          resource_serializer: Api::V1::BookSerializer
        )
      end

      def iterate
        book = Book.find(params[:id])
        message = params[:message] || params.dig(:book, :message)
        if message.blank?
          render_error(code: 'bad_request', message: 'Parameter :message is required for iterate', status: :bad_request)
          return
        end

        book.update(pending: true)

        enqueue_operation!(
          resource: book,
          operation_type: 'iterate',
          job_class: IterateOnBookPlotJob,
          metadata: { 'message' => message },
          resource_serializer: Api::V1::BookSerializer
        )
      end

      def render_book
        book = Book.find(params[:id])
        book.update(rendering: true)

        enqueue_operation!(
          resource: book,
          operation_type: 'render_book',
          job_class: RenderBookJob,
          resource_serializer: Api::V1::BookSerializer
        )
      end

      private

      def book_params
        extract_params(
          :book,
          :title, :moral, :plot, :chapter_count, :pages,
          :writing_style_id, :perspective_id, :narrative_structure_id,
          :poetic_form_id, :cinematic_style_id, :protagonist_id,
          antagonist_ids: [],
          character_ids: [],
          location_ids: []
        )
      end

      def find_versionable_resource
        Book.find(params[:book_id] || params[:id])
      end

      def versionable_serializer
        Api::V1::BookSerializer
      end

      def merge_job_class
        MergeBookPlotsJob
      end
    end
  end
end
