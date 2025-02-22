require 'rails_helper'

RSpec.describe Chapter, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:number) }
    it { should validate_presence_of(:summary) }
    it { should validate_presence_of(:content) }
    it { should validate_numericality_of(:number).only_integer.is_greater_than(0) }

    describe 'uniqueness' do
      subject { create(:chapter) }
      it { should validate_uniqueness_of(:number).scoped_to(:book_id).with_message("should be unique within the book") }
    end
  end

  describe 'associations' do
    it { should belong_to(:book) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:chapter)).to be_valid
    end

    it 'can create sequential chapters' do
      book = create(:book)
      chapters = create_list(:chapter, 3, :sequential, book: book)
      numbers = chapters.map(&:number)
      expect(numbers).to eq(numbers.sort)
      expect(numbers.uniq).to eq(numbers)
    end
  end
end
