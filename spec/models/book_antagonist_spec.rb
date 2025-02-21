require 'rails_helper'

RSpec.describe BookAntagonist, type: :model do
  describe 'associations' do
    it { should belong_to(:book) }
    it { should belong_to(:character) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:book_antagonist)).to be_valid
    end
  end
end
