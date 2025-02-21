require 'rails_helper'

RSpec.describe LocationsController, type: :controller do
  let(:user) { create(:user) }
  let(:location) { create(:location) }
  let(:valid_attributes) do
    {
      name: 'Test Location',
      description: 'A test location description',
      region_id: create(:region).id,
      lighting: 'Bright',
      time: 'Morning',
      noise_level: 'Quiet',
      comfort: 'Comfortable',
      aesthetics: 'Modern',
      accessibility: 'Easily Accessible',
      personalization: 'Personal touches'
    }
  end

  describe 'authentication' do
    context 'when user is not signed in' do
      before { sign_out :user }

      it 'redirects to sign in page' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is signed in but has no access' do
      before do
        user.update(has_access: false)
        sign_in user
      end

      it 'redirects to unauthorized page' do
        get :index
        expect(response).to redirect_to(unauthorized_index_path)
      end
    end

    context 'when user is signed in and has access' do
      before do
        user.update(has_access: true)
        sign_in user
      end

      it 'allows access to index' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end

  before do
    user.update(has_access: true)
    sign_in user
  end

  describe 'GET #index' do
    before do
      create_list(:location, 3)
      get :index
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @component_list' do
      expect(assigns(:component_list)).to be_present
    end

    it 'paginates results' do
      expect(assigns(:component_list)).to respond_to(:total_pages)
    end

    context 'with sorting' do
      before { Location.delete_all }

      it 'sorts by created_at in descending order by default' do
        second_location = create(:location, created_at: 2.days.ago)
        first_location = create(:location, created_at: 1.day.ago)
        get :index
        expect(assigns(:component_list).to_a).to eq([first_location, second_location])
      end
    end

    context 'with scoping' do
      before { Location.delete_all }

      let(:region) { create(:region) }
      let!(:location_one) { create(:location, region: region) }
      let!(:location_two) { create(:location) }

      it 'returns all locations by default' do
        get :index
        expect(assigns(:component_list)).to include(location_one, location_two)
      end

      it 'uses the default scope' do
        get :index
        expect(assigns(:component_list).to_sql).to include('ORDER BY "locations"."created_at" DESC')
      end
    end
  end

  describe 'GET #show' do
    before { get :show, params: { id: location.id } }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @component' do
      expect(assigns(:component)).to eq(location)
    end
  end

  describe 'GET #new' do
    before { get :new }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns a new location' do
      expect(assigns(:component)).to be_a_new(Location)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new location' do
        expect do
          post :create, params: { location: valid_attributes }
        end.to change(Location, :count).by(1)
      end

      it 'redirects to the locations list' do
        post :create, params: { location: valid_attributes }
        expect(response).to redirect_to(locations_path)
      end
    end

    context 'with invalid params' do
      it 'does not create a new location' do
        expect do
          post :create, params: { location: { name: '' } }
        end.not_to change(Location, :count)
      end

      it 'renders the new template' do
        post :create, params: { location: { name: '' } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    before { get :edit, params: { id: location.id } }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested location' do
      expect(assigns(:component)).to eq(location)
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { { name: 'Updated Location' } }

      it 'updates the requested location' do
        put :update, params: { id: location.id, location: new_attributes }
        location.reload
        expect(location.name).to eq('Updated Location')
      end

      it 'redirects to the locations list' do
        put :update, params: { id: location.id, location: new_attributes }
        expect(response).to redirect_to(locations_path)
      end
    end

    context 'with invalid params' do
      it 'does not update the location' do
        put :update, params: { id: location.id, location: { name: '' } }
        location.reload
        expect(location.name).not_to eq('')
      end

      it 'renders the edit template' do
        put :update, params: { id: location.id, location: { name: '' } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested location' do
      location_to_delete = create(:location)
      expect do
        delete :destroy, params: { id: location_to_delete.id }
      end.to change(Location, :count).by(-1)
    end

    it 'redirects to the locations list' do
      delete :destroy, params: { id: location.id }
      expect(response).to redirect_to(locations_path)
    end
  end

  describe 'GET #edit_prompt' do
    before { get :edit_prompt, params: { id: location.id } }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested location' do
      expect(assigns(:component)).to eq(location)
    end
  end

  describe 'POST #generate_prompt' do
    it 'enqueues a generate prompt job' do
      expect do
        post :generate_prompt, params: { id: location.id }, format: :turbo_stream
      end.to have_enqueued_job(GenerateLocationPromptJob)
    end

    it 'renders iterate template' do
      post :generate_prompt, params: { id: location.id }, format: :turbo_stream
      expect(response).to render_template(:iterate)
    end
  end

  describe 'POST #iterate' do
    let(:message) { 'Test message' }

    before do
      post :iterate, params: { id: location.id, message: message }, format: :turbo_stream
    end

    it 'sets the location as pending' do
      location.reload
      expect(location.pending).to be true
    end

    it 'enqueues an iterate job' do
      expect(IterateOnLocationPromptJob).to have_been_enqueued.with(location, message)
    end

    it 'renders iterate template' do
      expect(response).to render_template(:iterate)
    end
  end

  describe 'required implementations' do
    before do
      controller.instance_variable_set(:@computer_name, 'location')
    end

    it 'implements component_name' do
      expect(controller.send(:component_name)).to eq('Locations')
    end

    it 'implements component_class' do
      expect(controller.send(:component_class)).to eq(Location)
    end

    it 'implements iterate_job' do
      expect(controller.send(:iterate_job)).to eq(IterateOnLocationPromptJob)
    end

    it 'implements generate_prompt_job' do
      expect(controller.send(:generate_prompt_job)).to eq(GenerateLocationPromptJob)
    end

    it 'implements component_params' do
      params = ActionController::Parameters.new(
        location: valid_attributes
      )
      allow(controller).to receive(:params).and_return(params)

      permitted_params = controller.send(:component_params)
      expect(permitted_params).to be_permitted
      expect(permitted_params.keys).to include(*valid_attributes.keys.map(&:to_s))
    end
  end

  describe 'character associations' do
    let(:location_with_characters) { create(:location, :with_characters) }

    it 'includes associated characters in show' do
      get :show, params: { id: location_with_characters.id }
      expect(assigns(:component).characters).to be_present
    end

    it 'allows updating character associations' do
      characters = create_list(:character, 2)
      put :update, params: {
        id: location.id,
        location: { character_ids: characters.map(&:id) }
      }
      location.reload
      expect(location.characters).to match_array(characters)
    end
  end
end
