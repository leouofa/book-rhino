require 'rails_helper'

RSpec.describe LocationImagesController, type: :controller do
  let(:user) { create(:user, has_access: true) }
  let(:location) { create(:location) }
  let(:file) { Rack::Test::UploadedFile.new(StringIO.new('fake-location-image-bytes'), 'image/png', original_filename: 'cyberpunk_city.png') }

  before do
    sign_in user
  end

  describe 'POST #create' do
    it 'creates a new location image from upload and sets title from filename' do
      expect {
        post :create, params: { location_id: location.id, images: [file] }, format: :turbo_stream
      }.to change(LocationImage, :count).by(1)

      location_image = LocationImage.last
      expect(location_image.location).to eq(location)
      expect(location_image.title).to eq('Cyberpunk City')
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    let!(:location_image) { location.location_images.create!(title: 'Old Location Title') }

    it 'updates the title of the location image' do
      patch :update, params: { location_id: location.id, id: location_image.id, location_image: { title: 'Neon Alley' } }, format: :turbo_stream
      expect(response).to have_http_status(:success)
      expect(location_image.reload.title).to eq('Neon Alley')
    end
  end

  describe 'DELETE #destroy' do
    let!(:location_image) { location.location_images.create!(title: 'To Delete') }

    it 'destroys the location image' do
      expect {
        delete :destroy, params: { location_id: location.id, id: location_image.id }, format: :turbo_stream
      }.to change(LocationImage, :count).by(-1)
      expect(response).to have_http_status(:success)
    end
  end
end
