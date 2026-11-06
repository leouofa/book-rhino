# frozen_string_literal: true

module Api
  module V1
    class HealthController < BaseController
      skip_before_action :authenticate_api_token!
      skip_before_action :verify_user_access!

      def show
        render_data({
          status: 'ok',
          app: 'Book Rhino API',
          version: 'v1',
          time: Time.current.iso8601
        })
      end
    end
  end
end
