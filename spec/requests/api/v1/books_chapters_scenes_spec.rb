# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Books, Chapters & Scenes API', type: :request do
  let(:user) { create(:user, :with_access) }
  let(:token) { ApiToken.generate_for!(user: user, name: 'Key') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{token.raw_token}", 'Content-Type' => 'application/json' } }

  let!(:writing_style) { create(:writing_style) }
  let!(:perspective) { create(:perspective) }
  let!(:narrative_structure) { create(:narrative_structure) }

  describe 'Books CRUD' do
    it 'creates a book accepting a flat JSON payload' do
      payload = {
        title: 'The Great Journey',
        writing_style_id: writing_style.id,
        perspective_id: perspective.id,
        narrative_structure_id: narrative_structure.id,
        chapter_count: 10,
        pages: 200,
        plot: 'An intrepid explorer travels through the cosmos.'
      }

      post '/api/v1/books', params: payload.to_json, headers: auth_headers

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json.dig('data', 'title')).to eq('The Great Journey')
      expect(json.dig('data', 'plot')).to include('intrepid explorer')
    end

    it 'creates a book accepting a Rails-wrapped JSON payload' do
      payload = {
        book: {
          title: 'Wrapped Book',
          writing_style_id: writing_style.id,
          perspective_id: perspective.id,
          narrative_structure_id: narrative_structure.id
        }
      }

      post '/api/v1/books', params: payload.to_json, headers: auth_headers

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body).dig('data', 'title')).to eq('Wrapped Book')
    end

    it 'lists books with pagination and search' do
      create(:book, title: 'Alpha Tale')
      create(:book, title: 'Beta Chronicle')

      get '/api/v1/books?q=Alpha', headers: auth_headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data'].size).to eq(1)
      expect(json['data'].first['title']).to eq('Alpha Tale')
      expect(json['meta']['total_count']).to eq(1)
    end

    it 'exports full manuscript with chapters and markdown' do
      book = create(:book, title: 'Chronicles of Sol')
      chapter = create(:chapter, book: book, number: 1, name: 'The Awakening', content: 'In the beginning was the light.', summary: 'The light awakens.')
      create(:scene, chapter: chapter, number: 1, outline: 'Dawn breaks over the station.', content: 'Cinematic shot of dawn.')

      get "/api/v1/books/#{book.id}/manuscript", headers: auth_headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.dig('data', 'title')).to eq('Chronicles of Sol')
      expect(json.dig('data', 'markdown')).to include('# Chronicles of Sol')
      expect(json.dig('data', 'markdown')).to include('## Chapter 1: The Awakening')
      expect(json.dig('data', 'total_chapters')).to eq(1)
    end
  end

  describe 'Book AI Operations & Versioning' do
    let(:book) { create(:book) }

    it 'enqueues generate_prompt and returns 202 Accepted with operation' do
      expect {
        post "/api/v1/books/#{book.id}/generate_prompt", headers: auth_headers
      }.to have_enqueued_job(ExecuteOperationJob)

      expect(response).to have_http_status(:accepted)
      json = JSON.parse(response.body)
      expect(json.dig('data', 'operation', 'status')).to eq('queued')
      expect(json.dig('data', 'operation', 'operation_type')).to eq('generate_prompt')
    end

    it 'enqueues iterate with message and returns 202' do
      expect {
        post "/api/v1/books/#{book.id}/iterate", params: { message: 'Make it darker' }.to_json, headers: auth_headers
      }.to have_enqueued_job(ExecuteOperationJob)

      expect(response).to have_http_status(:accepted)
    end

    it 'tracks versions and allows revert' do
      book.update!(plot: 'Original Plot')
      book.update!(plot: 'Updated Plot')

      get "/api/v1/books/#{book.id}/versions", headers: auth_headers
      expect(response).to have_http_status(:ok)
      versions_json = JSON.parse(response.body)['data']
      expect(versions_json).not_to be_empty

      update_version = versions_json.find { |v| v['event'] == 'update' }
      post "/api/v1/books/#{book.id}/versions/#{update_version['id']}/revert", headers: auth_headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'Chapters and Scenes' do
    let(:book) { create(:book) }

    it 'creates, reads, updates, and deletes chapters' do
      chapter_params = { number: 1, name: 'Arrival', outline: 'The shuttle arrives.', scene_count: 3 }
      post "/api/v1/books/#{book.id}/chapters", params: chapter_params.to_json, headers: auth_headers

      expect(response).to have_http_status(:created)
      chapter_id = JSON.parse(response.body).dig('data', 'id')

      patch "/api/v1/chapters/#{chapter_id}", params: { name: 'Arrival on Mars' }.to_json, headers: auth_headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).dig('data', 'name')).to eq('Arrival on Mars')

      get "/api/v1/chapters/#{chapter_id}", headers: auth_headers
      expect(response).to have_http_status(:ok)

      delete "/api/v1/chapters/#{chapter_id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
    end

    it 'creates and renders scenes' do
      chapter = create(:chapter, book: book, number: 1, content: 'Some chapter content')

      post "/api/v1/chapters/#{chapter.id}/scenes", params: { number: 1, outline: 'Hero stands at the gate.' }.to_json, headers: auth_headers
      expect(response).to have_http_status(:created)
      scene_id = JSON.parse(response.body).dig('data', 'id')

      expect {
        post "/api/v1/scenes/#{scene_id}/render_scene", params: { shot_type: 'Close Up', style: 'Cyberpunk neon' }.to_json, headers: auth_headers
      }.to have_enqueued_job(ExecuteOperationJob)

      expect(response).to have_http_status(:accepted)
      json = JSON.parse(response.body)
      expect(json.dig('data', 'operation', 'metadata', 'shot_type')).to eq('Close Up')
    end
  end
end
