require 'rails_helper'

RSpec.describe CinematicStyle, type: :model do
  describe 'validations' do
    subject { build(:cinematic_style) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:aesthetic_tags) }
  end

  describe 'associations' do
    it { should have_many(:books).dependent(:nullify) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:cinematic_style)).to be_valid
    end
  end
end
