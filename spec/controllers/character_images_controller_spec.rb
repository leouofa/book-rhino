require 'rails_helper'

RSpec.describe CharacterImagesController, type: :controller do
  let(:user) { create(:user, has_access: true) }
  let(:character) { create(:character) }
  let(:file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/test.png'), 'image/png') rescue Rack::Test::UploadedFile.new(StringIO.new('fake-image-bytes'), 'image/png', original_filename: 'vox_portrait.png') }

  before do
    sign_in user
  end

  describe 'POST #create' do
    it 'creates a new character image from upload and sets title from filename' do
      expect {
        post :create, params: { character_id: character.id, images: [file] }, format: :turbo_stream
      }.to change(CharacterImage, :count).by(1)

      character_image = CharacterImage.last
      expect(character_image.character).to eq(character)
      expect(character_image.title).to eq('Vox Portrait')
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    let!(:character_image) { character.character_images.create!(title: 'Old Title') }

    it 'updates the title of the character image' do
      patch :update, params: { character_id: character.id, id: character_image.id, character_image: { title: 'New Renamed Title' } }, format: :turbo_stream
      expect(response).to have_http_status(:success)
      expect(character_image.reload.title).to eq('New Renamed Title')
    end
  end

  describe 'DELETE #destroy' do
    let!(:character_image) { character.character_images.create!(title: 'To Delete') }

    it 'destroys the character image' do
      expect {
        delete :destroy, params: { character_id: character.id, id: character_image.id }, format: :turbo_stream
      }.to change(CharacterImage, :count).by(-1)
      expect(response).to have_http_status(:success)
    end
  end
end
