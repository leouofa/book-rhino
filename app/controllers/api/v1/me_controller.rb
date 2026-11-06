# frozen_string_literal: true

module Api
  module V1
    class MeController < BaseController
      def show
        render_data(Api::V1::UserSerializer.render(current_user))
      end
    end
  end
end
