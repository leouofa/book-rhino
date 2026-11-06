# frozen_string_literal: true

module Api
  module V1
    class PoeticFormsController < ResourceController
      private

      def model_class
        PoeticForm
      end
    end
  end
end
