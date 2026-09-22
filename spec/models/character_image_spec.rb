require 'rails_helper'

RSpec.describe CharacterImage, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
  end

  describe 'associations' do
    it { should belong_to(:character) }
  end
end
