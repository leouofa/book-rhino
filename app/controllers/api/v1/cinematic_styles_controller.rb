# frozen_string_literal: true

module Api
  module V1
    class CinematicStylesController < ResourceController
      private

      def model_class
        CinematicStyle
      end
    end
  end
end
