# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OpenAPI Schema Endpoint', type: :request do
  describe 'GET /api/v1/openapi.json' do
    it 'returns valid OpenAPI 3.1 specification' do
      get '/api/v1/openapi.json'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['openapi']).to start_with('3.1')
      expect(json.dig('info', 'title')).to eq('Book Rhino Platform REST API')
      expect(json['paths']).to be_a(Hash)

      # Verify core path existence
      expect(json['paths']).to have_key('/health')
      expect(json['paths']).to have_key('/me')
      expect(json['paths']).to have_key('/api_tokens')
      expect(json['paths']).to have_key('/operations')
      expect(json['paths']).to have_key('/books')
      expect(json['paths']).to have_key('/books/{id}/manuscript')
      expect(json['paths']).to have_key('/chapters')
      expect(json['paths']).to have_key('/scenes')
      expect(json['paths']).to have_key('/characters')
      expect(json['paths']).to have_key('/locations')
      expect(json['paths']).to have_key('/writing_styles')
      expect(json['paths']).to have_key('/settings')
    end
  end
end
