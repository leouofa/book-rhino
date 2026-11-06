# frozen_string_literal: true

module Api
  module V1
    class PersonalityTraitsController < ResourceController
      private

      def model_class
        PersonalityTrait
      end
    end
  end
end
