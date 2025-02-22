require 'rails_helper'

RSpec.describe CharactersController, type: :controller do
  let(:user) { create(:user) }
  let(:character) { create(:character) }
  let(:valid_attributes) do
    {
      name: 'Test Character',
      gender: 'Non-binary',
      age: 25,
      ethnicity: 'Asian',
      nationality: 'Japanese',
      appearance: 'Tall with dark hair',
      health: 'Excellent condition',
      fears: 'Heights and spiders',
      desires: 'To become a master chef',
      backstory: 'Grew up in a small village',
      skills: 'Cooking, martial arts',
      values: 'Honor, loyalty, family',
      character_type_ids: [create(:character_type).id],
      moral_alignment_ids: [create(:moral_alignment).id],
      personality_trait_ids: [create(:personality_trait).id],
      archetype_ids: [create(:archetype).id]
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
      create_list(:character, 3)
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
      before { Character.delete_all }

      it 'sorts by created_at in descending order by default' do
        second_character = create(:character, created_at: 2.days.ago)
        first_character = create(:character, created_at: 1.day.ago)
        get :index
        expect(assigns(:component_list).to_a).to eq([first_character, second_character])
      end
    end
  end

  describe 'GET #show' do
    before { get :show, params: { id: character.id } }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @component' do
      expect(assigns(:component)).to eq(character)
    end
  end

  describe 'GET #new' do
    before { get :new }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns a new character' do
      expect(assigns(:component)).to be_a_new(Character)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new character' do
        expect do
          post :create, params: { character: valid_attributes }
        end.to change(Character, :count).by(1)
      end

      it 'redirects to the characters list' do
        post :create, params: { character: valid_attributes }
        expect(response).to redirect_to(characters_path)
      end
    end

    context 'with invalid params' do
      it 'does not create a new character' do
        expect do
          post :create, params: { character: { name: '' } }
        end.not_to change(Character, :count)
      end

      it 'renders the new template' do
        post :create, params: { character: { name: '' } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    before { get :edit, params: { id: character.id } }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested character' do
      expect(assigns(:component)).to eq(character)
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { { name: 'Updated Character' } }

      it 'updates the requested character' do
        put :update, params: { id: character.id, character: new_attributes }
        character.reload
        expect(character.name).to eq('Updated Character')
      end

      it 'redirects to the characters list' do
        put :update, params: { id: character.id, character: new_attributes }
        expect(response).to redirect_to(characters_path)
      end
    end

    context 'with invalid params' do
      it 'does not update the character' do
        put :update, params: { id: character.id, character: { name: '' } }
        character.reload
        expect(character.name).not_to eq('')
      end

      it 'renders the edit template' do
        put :update, params: { id: character.id, character: { name: '' } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested character' do
      character_to_delete = create(:character)
      expect do
        delete :destroy, params: { id: character_to_delete.id }
      end.to change(Character, :count).by(-1)
    end

    it 'redirects to the characters list' do
      delete :destroy, params: { id: character.id }
      expect(response).to redirect_to(characters_path)
    end
  end

  describe 'GET #edit_prompt' do
    before { get :edit_prompt, params: { id: character.id } }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested character' do
      expect(assigns(:component)).to eq(character)
    end
  end

  describe 'POST #generate_prompt' do
    it 'enqueues a generate prompt job' do
      expect do
        post :generate_prompt, params: { id: character.id }, format: :turbo_stream
      end.to have_enqueued_job(GenerateCharacterPromptJob)
    end

    it 'renders iterate template' do
      post :generate_prompt, params: { id: character.id }, format: :turbo_stream
      expect(response).to render_template(:iterate)
    end
  end

  describe 'POST #iterate' do
    let(:message) { 'Test message' }

    before do
      post :iterate, params: { id: character.id, message: message }, format: :turbo_stream
    end

    it 'sets the character as pending' do
      character.reload
      expect(character.pending).to be true
    end

    it 'enqueues an iterate job' do
      expect(IterateOnCharacterPromptJob).to have_been_enqueued.with(character, message)
    end

    it 'renders iterate template' do
      expect(response).to render_template(:iterate)
    end
  end

  describe 'required implementations' do
    before do
      controller.instance_variable_set(:@computer_name, 'character')
    end

    it 'implements component_name' do
      expect(controller.send(:component_name)).to eq('Characters')
    end

    it 'implements component_class' do
      expect(controller.send(:component_class)).to eq(Character)
    end

    it 'implements iterate_job' do
      expect(controller.send(:iterate_job)).to eq(IterateOnCharacterPromptJob)
    end

    it 'implements generate_prompt_job' do
      expect(controller.send(:generate_prompt_job)).to eq(GenerateCharacterPromptJob)
    end

    it 'implements component_params' do
      params = ActionController::Parameters.new(
        character: valid_attributes
      )
      allow(controller).to receive(:params).and_return(params)

      permitted_params = controller.send(:component_params)
      expect(permitted_params).to be_permitted
      expect(permitted_params.keys).to include(*valid_attributes.keys.map(&:to_s))
    end
  end

  describe 'associations' do
    let(:character_with_associations) { create(:character, :with_associations) }

    it 'includes associated models in show' do
      get :show, params: { id: character_with_associations.id }
      expect(assigns(:component).character_types).to be_present
      expect(assigns(:component).moral_alignments).to be_present
      expect(assigns(:component).personality_traits).to be_present
      expect(assigns(:component).archetypes).to be_present
    end

    it 'allows updating associations' do
      character_type = create(:character_type)
      moral_alignment = create(:moral_alignment)
      personality_trait = create(:personality_trait)
      archetype = create(:archetype)

      put :update, params: {
        id: character.id,
        character: {
          character_type_ids: [character_type.id],
          moral_alignment_ids: [moral_alignment.id],
          personality_trait_ids: [personality_trait.id],
          archetype_ids: [archetype.id]
        }
      }

      character.reload
      expect(character.character_types).to include(character_type)
      expect(character.moral_alignments).to include(moral_alignment)
      expect(character.personality_traits).to include(personality_trait)
      expect(character.archetypes).to include(archetype)
    end
  end
end
