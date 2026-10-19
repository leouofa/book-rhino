require 'rails_helper'

RSpec.describe PoeticForm, type: :model do
  describe 'validations' do
    subject { build(:poetic_form) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'associations' do
    it { should have_many(:books).dependent(:nullify) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:poetic_form)).to be_valid
    end
  end
end
