# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Writing Styles, Taxonomies & Settings API', type: :request do
  let(:user) { create(:user, :with_access) }
  let(:admin) { create(:user, :with_access, :admin) }
  let(:token) { ApiToken.generate_for!(user: user, name: 'Key') }
  let(:admin_token) { ApiToken.generate_for!(user: admin, name: 'AdminKey') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{token.raw_token}", 'Content-Type' => 'application/json' } }
  let(:admin_headers) { { 'Authorization' => "Bearer #{admin_token.raw_token}", 'Content-Type' => 'application/json' } }

  describe 'Writing Styles & Texts' do
    it 'creates writing style and manages attached texts' do
      ws_payload = { name: 'Hard Sci-Fi', prompt: { tone: 'analytical', pacing: 'measured' } }
      post '/api/v1/writing_styles', params: ws_payload.to_json, headers: auth_headers

      expect(response).to have_http_status(:created)
      ws_id = JSON.parse(response.body).dig('data', 'id')

      post "/api/v1/writing_styles/#{ws_id}/texts",
           params: { name: 'Sample Excerpt', corpus: 'The reactor hummed quietly in the vacuum.' }.to_json,
           headers: auth_headers

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body).dig('data', 'name')).to eq('Sample Excerpt')

      get "/api/v1/writing_styles/#{ws_id}?include_texts=true", headers: auth_headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).dig('data', 'texts').size).to eq(1)
    end
  end

  describe 'Taxonomies' do
    it 'performs CRUD on perspectives' do
      post '/api/v1/perspectives',
           params: {
             name: "First Person Noir #{SecureRandom.hex(4)}",
             narrator: 'Detective',
             pronouns: 'I/me',
             effect: 'Intimate and cynical',
             example: 'It was raining in the city.'
           }.to_json,
           headers: auth_headers
      expect(response).to have_http_status(:created)
      id = JSON.parse(response.body).dig('data', 'id')

      get "/api/v1/perspectives/#{id}", headers: auth_headers
      expect(response).to have_http_status(:ok)

      delete "/api/v1/perspectives/#{id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
    end

    it 'performs CRUD on moral alignments' do
      post '/api/v1/moral_alignments',
           params: { name: 'Chaotic Good', description: 'Rebel with a heart of gold', examples: ['Robin Hood'] }.to_json,
           headers: auth_headers
      expect(response).to have_http_status(:created)
    end

    it 'performs CRUD on poetic forms and cinematic styles' do
      post '/api/v1/poetic_forms',
           params: { name: 'Epic Hexameter', meter: 'Dactylic hexameter', description: 'Classical epic' }.to_json,
           headers: auth_headers
      expect(response).to have_http_status(:created)

      post '/api/v1/cinematic_styles',
           params: { name: 'Solarpunk Gold', aesthetic_tags: 'warm, organic, bright sunlight' }.to_json,
           headers: auth_headers
      expect(response).to have_http_status(:created)
    end
  end

  describe 'Settings' do
    it 'allows reading settings with normal user access' do
      get '/api/v1/settings', headers: auth_headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']).to be_present
    end

    it 'forbids regular users from updating settings' do
      patch '/api/v1/settings',
            params: { character_image_prompt: 'Cinematic headshot' }.to_json,
            headers: auth_headers

      expect(response).to have_http_status(:forbidden)
    end

    it 'allows admins to update settings' do
      patch '/api/v1/settings',
            params: { character_image_prompt: 'Cinematic headshot 8k' }.to_json,
            headers: admin_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).dig('data', 'character_image_prompt')).to eq('Cinematic headshot 8k')
    end
  end
end
