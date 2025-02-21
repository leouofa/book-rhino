require 'rails_helper'

RSpec.describe Character, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_numericality_of(:age).only_integer.is_greater_than(0).allow_nil }
  end

  describe 'associations' do
    it { should have_and_belong_to_many(:character_types) }
    it { should have_and_belong_to_many(:moral_alignments) }
    it { should have_and_belong_to_many(:personality_traits) }
    it { should have_and_belong_to_many(:archetypes) }
    it { should have_and_belong_to_many(:locations) }
    it { should have_and_belong_to_many(:books) }
    it { should have_many(:protagonist_books).class_name('Book') }
    it { should have_many(:book_antagonists) }
    it { should have_many(:antagonist_books).through(:book_antagonists) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:character)).to be_valid
    end

    it 'has a valid factory with associations' do
      expect(create(:character, :with_associations)).to be_valid
    end

    it 'can be created as a protagonist' do
      character = create(:character, :as_protagonist)
      expect(character.protagonist_books).to be_present
    end

    it 'can be created as an antagonist' do
      character = create(:character, :as_antagonist)
      expect(character.antagonist_books).to be_present
    end
  end

  describe '#as_json' do
    let(:character) { create(:character, :with_associations) }
    let(:json) { character.as_json }

    it 'excludes specified attributes' do
      expect(json.keys).not_to include('id', 'prompt', 'pending', 'created_at', 'updated_at')
    end

    it 'includes associated models' do
      expect(json['character_types']).to be_present
      expect(json['moral_alignments']).to be_present
      expect(json['personality_traits']).to be_present
      expect(json['archetypes']).to be_present
    end
  end
end
