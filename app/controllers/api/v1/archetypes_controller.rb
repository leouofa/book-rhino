# frozen_string_literal: true

module Api
  module V1
    class ArchetypesController < ResourceController
      private

      def model_class
        Archetype
      end
    end
  end
end
