# frozen_string_literal: true

module Api
  module V1
    class ApiTokensController < BaseController
      def index
        tokens = current_user.api_tokens.order(created_at: :desc)
        render_paginated(tokens, serializer: Api::V1::ApiTokenSerializer)
      end

      def create
        token_params = extract_params(:api_token, :name, :expires_at)
        token = ApiToken.generate_for!(
          user: current_user,
          name: token_params[:name],
          expires_at: token_params[:expires_at].presence
        )

        render_data(Api::V1::ApiTokenSerializer.render(token), status: :created)
      end

      def destroy
        token = current_user.api_tokens.find(params[:id])
        token.revoke!
        render_data(Api::V1::ApiTokenSerializer.render(token))
      end
    end
  end
end
