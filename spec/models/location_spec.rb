require 'rails_helper'

RSpec.describe Location, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }

    describe 'uniqueness' do
      subject { create(:location) }
      it { should validate_uniqueness_of(:name) }
    end
  end

  describe 'associations' do
    it { should belong_to(:region).optional }
    it { should have_and_belong_to_many(:characters) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:location)).to be_valid
    end

    it 'can be created with characters' do
      location = create(:location, :with_characters)
      expect(location.characters.count).to eq(2)
    end
  end

  describe '#location_details' do
    let(:location) { create(:location, :with_characters) }
    let(:details) { location.location_details }

    it 'excludes specified attributes' do
      expect(details.keys).not_to include('id', 'prompt', 'pending')
    end

    it 'includes characters with limited attributes' do
      expect(details['characters']).to be_present
      details['characters'].each do |character|
        expect(character.keys).to match_array(%w[name prompt])
      end
    end
  end
end
