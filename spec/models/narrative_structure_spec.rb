require 'rails_helper'

RSpec.describe NarrativeStructure, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'associations' do
    it { should have_many(:books) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:narrative_structure)).to be_valid
    end
  end
end
