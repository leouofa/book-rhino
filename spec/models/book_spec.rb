require 'rails_helper'

RSpec.describe Book, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
  end

  describe 'associations' do
    it { should belong_to(:writing_style) }
    it { should belong_to(:perspective) }
    it { should belong_to(:narrative_structure) }
    it { should belong_to(:protagonist).class_name('Character').optional }
    it { should have_many(:book_antagonists) }
    it { should have_many(:antagonists).through(:book_antagonists) }
    it { should have_and_belong_to_many(:characters) }
    it { should have_many(:chapters).dependent(:destroy) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:book)).to be_valid
    end

    it 'can be created with a protagonist' do
      book = create(:book, :with_protagonist)
      expect(book.protagonist).to be_present
    end

    it 'can be created with antagonists' do
      book = create(:book, :with_antagonists)
      expect(book.antagonists).to be_present
    end

    it 'can be created with characters' do
      book = create(:book, :with_characters)
      expect(book.characters).to be_present
    end

    it 'can be created as complete' do
      book = create(:book, :complete)
      expect(book.protagonist).to be_present
      expect(book.antagonists).to be_present
      expect(book.characters).to be_present
    end
  end

  describe 'character role uniqueness validation' do
    let(:character) { create(:character) }
    let(:book) { create(:book, protagonist: character) }

    context 'when character is both protagonist and antagonist' do
      before do
        book.antagonists << character
        book.save
      end

      it 'is invalid' do
        expect(book).not_to be_valid
        expect(book.errors[:protagonist_id]).to include("can't be both protagonist and antagonist")
      end
    end

    context 'when character is both protagonist and regular character' do
      before do
        book.characters << character
        book.save
      end

      it 'is invalid' do
        expect(book).not_to be_valid
        expect(book.errors[:protagonist_id]).to include("can't be both protagonist and regular character")
      end
    end

    context 'when character is both antagonist and regular character' do
      let(:character) { create(:character) }
      let(:book) { create(:book) }

      before do
        book.antagonists << character
        book.characters << character
        book.save
      end

      it 'is invalid' do
        expect(book).not_to be_valid
        expect(book.errors[:antagonists]).to include("can't be both antagonists and regular characters")
      end
    end
  end
end
