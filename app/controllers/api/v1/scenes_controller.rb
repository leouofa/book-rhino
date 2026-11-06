# frozen_string_literal: true

module Api
  module V1
    class ScenesController < BaseController
      include Concerns::AiActionable

      def index
        scope = Scene.all
        if params[:chapter_id].present?
          scope = scope.where(chapter_id: params[:chapter_id])
        elsif params[:book_id].present?
          scope = scope.joins(:chapter).where(chapters: { book_id: params[:book_id] })
        end
        scope = scope.where(rendering: ActiveModel::Type::Boolean.new.cast(params[:rendering])) if params[:rendering].present?
        scope = scope.order(number: :asc)

        render_paginated(scope, serializer: Api::V1::SceneSerializer)
      end

      def show
        scene = Scene.find(params[:id])
        render_data(Api::V1::SceneSerializer.render(scene))
      end

      def create
        chapter_id = params[:chapter_id] || params.dig(:scene, :chapter_id)
        chapter = Chapter.find(chapter_id)

        scene = chapter.scenes.build(scene_params)
        scene.save!
        render_data(Api::V1::SceneSerializer.render(scene), status: :created)
      end

      def update
        scene = Scene.find(params[:id])
        scene.update!(scene_params)
        render_data(Api::V1::SceneSerializer.render(scene))
      end

      def destroy
        scene = Scene.find(params[:id])
        scene.destroy!
        render_data({ id: scene.id, deleted: true })
      end

      def render_scene
        scene = Scene.find(params[:id])
        scene.update(rendering: true)

        metadata = {}
        metadata['shot_type'] = params[:shot_type] if params[:shot_type].present?
        metadata['style'] = params[:style] if params[:style].present?

        enqueue_operation!(
          resource: scene,
          operation_type: 'render_scene',
          job_class: RenderSceneJob,
          metadata: metadata,
          resource_serializer: Api::V1::SceneSerializer
        )
      end

      private

      def scene_params
        extract_params(:scene, :number, :outline, :content, :summary, :chapter_id)
      end
    end
  end
end
