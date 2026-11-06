# frozen_string_literal: true

module Api
  module V1
    class PerspectivesController < ResourceController
      private

      def model_class
        Perspective
      end
    end
  end
end
