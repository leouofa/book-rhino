# frozen_string_literal: true

class ApiTokensController < ApplicationController
  include RestrictedAccess

  def index
    @api_tokens = current_user.api_tokens.order(created_at: :desc)
    @new_token = current_user.api_tokens.build
  end

  def create
    @token = ApiToken.generate_for!(
      user: current_user,
      name: token_params[:name],
      expires_at: token_params[:expires_at].presence
    )
    flash[:raw_token] = @token.raw_token
    redirect_to api_tokens_path, notice: "API Token '#{@token.name}' created successfully."
  rescue ActiveRecord::RecordInvalid => e
    @api_tokens = current_user.api_tokens.order(created_at: :desc)
    @new_token = current_user.api_tokens.build(token_params)
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    render :index, status: :unprocessable_entity
  end

  def destroy
    token = current_user.api_tokens.find(params[:id])
    token.revoke!
    redirect_to api_tokens_path, notice: "API Token '#{token.name}' was revoked."
  end

  private

  def token_params
    params.require(:api_token).permit(:name, :expires_at)
  end
end
