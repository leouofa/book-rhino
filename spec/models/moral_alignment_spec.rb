require 'rails_helper'

RSpec.describe MoralAlignment, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'associations' do
    it { should have_and_belong_to_many(:characters) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:moral_alignment)).to be_valid
    end
  end
end
