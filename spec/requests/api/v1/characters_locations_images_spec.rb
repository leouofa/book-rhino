# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Characters, Locations & Images API', type: :request do
  let(:user) { create(:user, :with_access) }
  let(:token) { ApiToken.generate_for!(user: user, name: 'Key') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{token.raw_token}", 'Content-Type' => 'application/json' } }

  describe 'Characters & Images' do
    it 'creates, reads, updates, and uploads images for a character' do
      char_payload = {
        name: 'Elena Vance',
        gender: 'Female',
        age: 32,
        ethnicity: 'Mixed',
        nationality: 'Martian',
        backstory: 'Former pilot turned investigator.'
      }

      post '/api/v1/characters', params: char_payload.to_json, headers: auth_headers
      expect(response).to have_http_status(:created)
      character_id = JSON.parse(response.body).dig('data', 'id')

      # Upload image via base64
      tiny_png = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII='
      post "/api/v1/characters/#{character_id}/images",
           params: { title: 'Portrait', image_base64: tiny_png }.to_json,
           headers: auth_headers

      expect(response).to have_http_status(:created)
      img_json = JSON.parse(response.body)['data']
      expect(img_json['title']).to eq('Portrait')
      expect(img_json['image']['url']).to be_present

      image_id = img_json['id']
      patch "/api/v1/character_images/#{image_id}", params: { title: 'Updated Portrait' }.to_json, headers: auth_headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).dig('data', 'title')).to eq('Updated Portrait')

      delete "/api/v1/character_images/#{image_id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'Locations & Regions' do
    it 'creates a region and a location in that region' do
      post '/api/v1/regions',
           params: {
             name: "Valles Marineris #{SecureRandom.hex(4)}",
             city: 'Canyon Base',
             country: 'Mars',
             description: 'A vast canyon system.'
           }.to_json,
           headers: auth_headers
      expect(response).to have_http_status(:created)
      region_id = JSON.parse(response.body).dig('data', 'id')

      loc_payload = {
        name: "The Rusty Habitat #{SecureRandom.hex(4)}",
        description: 'A weathered geodesic dome.',
        region_id: region_id,
        lighting: 'Dim fluorescent amber',
        comfort: 'Spartan'
      }
      post '/api/v1/locations', params: loc_payload.to_json, headers: auth_headers
      expect(response).to have_http_status(:created)
      location_id = JSON.parse(response.body).dig('data', 'id')

      get "/api/v1/locations/#{location_id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).dig('data', 'region', 'id')).to eq(region_id)
    end
  end
end
