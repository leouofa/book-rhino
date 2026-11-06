# frozen_string_literal: true

module Api
  module V1
    class MoralAlignmentsController < ResourceController
      private

      def model_class
        MoralAlignment
      end

      def permitted_params
        extract_params(:moral_alignment, :name, :description, examples: [])
      end
    end
  end
end
