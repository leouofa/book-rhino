# frozen_string_literal: true

module Api
  module V1
    class NarrativeStructuresController < ResourceController
      private

      def model_class
        NarrativeStructure
      end

      def permitted_params
        extract_params(:narrative_structure, :name, :description, parts: {})
      end
    end
  end
end
