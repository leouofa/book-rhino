# frozen_string_literal: true

module Api
  module V1
    class ChaptersController < BaseController
      include Concerns::AiActionable

      def index
        scope = Chapter.all
        book_id = params[:book_id] || params.dig(:chapter, :book_id)
        scope = scope.where(book_id: book_id) if book_id.present?
        scope = scope.where(rendering: ActiveModel::Type::Boolean.new.cast(params[:rendering])) if params[:rendering].present?
        scope = scope.order(number: :asc)

        include_scenes = ActiveModel::Type::Boolean.new.cast(params[:include_scenes])
        render_paginated(scope, serializer: Api::V1::ChapterSerializer, include_scenes: include_scenes)
      end

      def show
        chapter = Chapter.find(params[:id])
        include_scenes = params.key?(:include_scenes) ? ActiveModel::Type::Boolean.new.cast(params[:include_scenes]) : true
        render_data(Api::V1::ChapterSerializer.render(chapter, include_scenes: include_scenes))
      end

      def create
        book_id = params[:book_id] || params.dig(:chapter, :book_id)
        book = Book.find(book_id)

        chapter = book.chapters.build(chapter_params)
        chapter.save!
        render_data(Api::V1::ChapterSerializer.render(chapter), status: :created)
      end

      def update
        chapter = Chapter.find(params[:id])
        chapter.update!(chapter_params)
        render_data(Api::V1::ChapterSerializer.render(chapter))
      end

      def destroy
        chapter = Chapter.find(params[:id])
        chapter.destroy!
        render_data({ id: chapter.id, deleted: true })
      end

      def render_chapter
        chapter = Chapter.find(params[:id])

        unless chapter.can_render?
          render_error(
            code: 'cannot_render',
            message: 'Previous chapter must be rendered first.',
            status: :unprocessable_entity
          )
          return
        end

        chapter.update(rendering: true)

        enqueue_operation!(
          resource: chapter,
          operation_type: 'render_chapter',
          job_class: RenderChapterJob,
          resource_serializer: Api::V1::ChapterSerializer
        )
      end

      def generate_scenes
        chapter = Chapter.find(params[:id])

        unless chapter.scene_count.to_i > 0 && chapter.content.present?
          render_error(
            code: 'cannot_generate_scenes',
            message: 'Chapter must be rendered with content and have a scene count greater than 0.',
            status: :unprocessable_entity
          )
          return
        end

        enqueue_operation!(
          resource: chapter,
          operation_type: 'generate_scenes',
          job_class: WriteScenesJob,
          metadata: { 'chapter_id' => chapter.id },
          resource_serializer: Api::V1::ChapterSerializer
        )
      end

      private

      def chapter_params
        extract_params(:chapter, :number, :name, :outline, :content, :summary, :scene_count, :book_id)
      end
    end
  end
end
