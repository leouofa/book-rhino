require 'rails_helper'

RSpec.describe Region, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:country) }
    it { should validate_presence_of(:description) }

    describe 'uniqueness' do
      subject { create(:region) }
      it { should validate_uniqueness_of(:name) }
    end
  end

  describe 'associations' do
    it { should have_many(:locations).dependent(:nullify) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:region)).to be_valid
    end

    it 'can be created with locations' do
      region = create(:region, :with_locations)
      expect(region.locations.count).to eq(3)
    end
  end
end
