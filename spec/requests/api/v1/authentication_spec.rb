# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Authentication & Token Management', type: :request do
  let(:user) { create(:user, :with_access) }
  let(:token) { ApiToken.generate_for!(user: user, name: 'Test Key') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{token.raw_token}" } }

  describe 'GET /api/v1/health' do
    it 'returns ok without authentication' do
      get '/api/v1/health'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.dig('data', 'status')).to eq('ok')
    end
  end

  describe 'GET /api/v1/me' do
    it 'returns 401 when Authorization header is missing' do
      get '/api/v1/me'

      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body)
      expect(json.dig('error', 'code')).to eq('unauthorized')
    end

    it 'returns 401 when token is invalid' do
      get '/api/v1/me', headers: { 'Authorization' => 'Bearer br_live_fakefakefake' }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 401 when token has been revoked' do
      token.revoke!
      get '/api/v1/me', headers: auth_headers

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 403 when user has_access is false' do
      user.remove_access
      get '/api/v1/me', headers: auth_headers

      expect(response).to have_http_status(:forbidden)
      json = JSON.parse(response.body)
      expect(json.dig('error', 'code')).to eq('forbidden')
    end

    it 'returns 200 with user profile when token and access are valid' do
      get '/api/v1/me', headers: auth_headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.dig('data', 'email')).to eq(user.email)
      expect(json.dig('data', 'has_access')).to be true
    end
  end

  describe 'Token CRUD via API' do
    it 'creates a new token returning the raw token once' do
      post '/api/v1/api_tokens', params: { name: 'MCP CLI' }.to_json,
                                 headers: auth_headers.merge('Content-Type' => 'application/json')

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json.dig('data', 'name')).to eq('MCP CLI')
      expect(json.dig('data', 'token')).to start_with('br_live_')
    end

    it 'lists tokens for current user' do
      get '/api/v1/api_tokens', headers: auth_headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']).to be_an(Array)
      expect(json['meta']).to be_present
    end

    it 'revokes a token' do
      token_to_revoke = ApiToken.generate_for!(user: user, name: 'To Revoke')

      delete "/api/v1/api_tokens/#{token_to_revoke.id}", headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(token_to_revoke.reload.active?).to be false
    end
  end

  describe 'CORS support' do
    it 'responds to OPTIONS preflight with CORS headers' do
      options '/api/v1/books', headers: {
        'Origin' => 'http://localhost:5173',
        'Access-Control-Request-Method' => 'POST',
        'Access-Control-Request-Headers' => 'Authorization, Content-Type'
      }

      expect(response).to have_http_status(:ok)
      expect(response.headers['Access-Control-Allow-Origin']).to be_present
      expect(response.headers['Access-Control-Allow-Methods']).to include('POST')
    end
  end
end
