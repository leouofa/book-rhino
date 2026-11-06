# frozen_string_literal: true

module Api
  module V1
    class CharactersController < BaseController
      include Concerns::AiActionable
      include Concerns::VersionableActions

      def index
        scope = Character.all
        if params[:q].present?
          scope = scope.where('name ILIKE ?', "%#{params[:q].to_s.strip}%")
        end
        if params[:book_id].present?
          scope = scope.joins(:books).where(books: { id: params[:book_id] })
        end
        scope = scope.order(name: :asc)

        render_paginated(scope, serializer: Api::V1::CharacterSerializer)
      end

      def show
        character = Character.find(params[:id])
        render_data(Api::V1::CharacterSerializer.render(character, detailed: true))
      end

      def create
        character = Character.new(character_params)
        character.save!
        render_data(Api::V1::CharacterSerializer.render(character, detailed: true), status: :created)
      end

      def update
        character = Character.find(params[:id])
        character.update!(character_params)
        render_data(Api::V1::CharacterSerializer.render(character, detailed: true))
      end

      def destroy
        character = Character.find(params[:id])
        character.destroy!
        render_data({ id: character.id, deleted: true })
      end

      def generate_prompt
        character = Character.find(params[:id])
        character.update(pending: true)

        enqueue_operation!(
          resource: character,
          operation_type: 'generate_prompt',
          job_class: GenerateCharacterPromptJob,
          resource_serializer: Api::V1::CharacterSerializer
        )
      end

      def iterate
        character = Character.find(params[:id])
        message = params[:message] || params.dig(:character, :message)
        if message.blank?
          render_error(code: 'bad_request', message: 'Parameter :message is required for iterate', status: :bad_request)
          return
        end

        character.update(pending: true)

        enqueue_operation!(
          resource: character,
          operation_type: 'iterate',
          job_class: IterateOnCharacterPromptJob,
          metadata: { 'message' => message },
          resource_serializer: Api::V1::CharacterSerializer
        )
      end

      private

      def character_params
        extract_params(
          :character,
          :name, :gender, :age, :ethnicity, :nationality, :appearance,
          :health, :fears, :desires, :backstory, :skills, :values, :prompt,
          character_type_ids: [],
          moral_alignment_ids: [],
          personality_trait_ids: [],
          archetype_ids: [],
          location_ids: []
        )
      end

      def find_versionable_resource
        Character.find(params[:character_id] || params[:id])
      end

      def versionable_serializer
        Api::V1::CharacterSerializer
      end

      def merge_job_class
        MergeCharacterPromptsJob
      end
    end
  end
end
