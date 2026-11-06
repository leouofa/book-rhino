# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      wrap_parameters false

      before_action :authenticate_api_token!
      before_action :verify_user_access!
      before_action :set_paper_trail_whodunnit

      rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
      rescue_from ActionController::ParameterMissing, with: :handle_bad_request
      rescue_from ActionDispatch::Http::Parameters::ParseError, with: :handle_bad_request
      rescue_from Api::ImageAttacher::AttachmentError, with: :handle_attachment_error

      attr_reader :current_user, :current_api_token

      private

      def authenticate_api_token!
        header = request.headers['Authorization'].to_s
        token_string = header.start_with?('Bearer ') ? header.sub(/\ABearer\s+/, '') : nil

        if token_string.blank?
          render_error(
            code: 'unauthorized',
            message: 'Missing or malformed Authorization header. Expected Bearer token.',
            status: :unauthorized
          )
          return
        end

        token = ApiToken.authenticate(token_string)
        if token.nil?
          render_error(
            code: 'unauthorized',
            message: 'Invalid, expired, or revoked API token.',
            status: :unauthorized
          )
          return
        end

        @current_api_token = token
        @current_user = token.user
      end

      def verify_user_access!
        return if current_user&.has_access?

        render_error(
          code: 'forbidden',
          message: 'Your account does not have access to this application.',
          status: :forbidden
        )
      end

      def require_admin!
        return if current_user&.admin?

        render_error(
          code: 'forbidden',
          message: 'Admin privileges required for this action.',
          status: :forbidden
        )
      end

      def set_paper_trail_whodunnit
        PaperTrail.request.whodunnit = current_user&.id
      end

      # Response formatters
      def render_data(data = {}, meta: nil, status: :ok)
        payload = { data: data }
        payload[:meta] = meta if meta.present?
        render json: payload, status: status
      end

      def render_paginated(scope, serializer:, **serializer_opts)
        page = [params[:page].to_i, 1].max
        per_page = [[params[:per_page].present? ? params[:per_page].to_i : 25, 1].max, 100].min

        paginated = scope.page(page).per(per_page)
        meta = {
          page: paginated.current_page,
          per_page: paginated.limit_value,
          total_pages: paginated.total_pages,
          total_count: paginated.total_count
        }

        render_data(serializer.render(paginated, **serializer_opts), meta: meta)
      end

      def render_error(code:, message:, details: nil, status:)
        error_payload = {
          code: code,
          message: message
        }
        error_payload[:details] = details if details.present?
        render json: { error: error_payload }, status: status
      end

      def extract_params(root_key, *scalars, **hashes)
        source = if params[root_key].is_a?(ActionController::Parameters) && params[root_key].present?
                   params[root_key]
                 else
                   params
                 end
        source.permit(*scalars, **hashes)
      end

      # Exception handlers
      def handle_not_found(exception)
        render_error(
          code: 'not_found',
          message: exception.message,
          status: :not_found
        )
      end

      def handle_record_invalid(exception)
        render_error(
          code: 'validation_error',
          message: exception.record.errors.full_messages.to_sentence,
          details: exception.record.errors.messages,
          status: :unprocessable_entity
        )
      end

      def handle_bad_request(exception)
        render_error(
          code: 'bad_request',
          message: exception.message,
          status: :bad_request
        )
      end

      def handle_attachment_error(exception)
        render_error(
          code: 'attachment_error',
          message: exception.message,
          status: :unprocessable_entity
        )
      end
    end
  end
end
