# frozen_string_literal: true

module Api
  module V1
    class CharacterTypesController < ResourceController
      private

      def model_class
        CharacterType
      end
    end
  end
end
