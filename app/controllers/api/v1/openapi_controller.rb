# frozen_string_literal: true

require 'yaml'
require 'date'

module Api
  module V1
    class OpenapiController < BaseController
      skip_before_action :authenticate_api_token!
      skip_before_action :verify_user_access!

      def show
        spec_path = Rails.root.join('docs', 'openapi.yaml')
        if File.exist?(spec_path)
          parsed = YAML.safe_load_file(spec_path, permitted_classes: [Date, Time], aliases: true)
          render json: parsed
        else
          render_error(
            code: 'not_found',
            message: 'OpenAPI specification file not found.',
            status: :not_found
          )
        end
      end
    end
  end
end
