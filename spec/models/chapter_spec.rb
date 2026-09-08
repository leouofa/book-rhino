require 'rails_helper'

RSpec.describe Chapter, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:number) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:plot_summary) }
    it { should validate_numericality_of(:number).only_integer.is_greater_than(0) }

    describe 'uniqueness' do
      subject { create(:chapter) }
      it { should validate_uniqueness_of(:number).scoped_to(:book_id).with_message('should be unique within the book') }
    end
  end

  describe 'associations' do
    it { should belong_to(:book) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:chapter)).to be_valid
    end

    describe 'sequential chapters' do
      before do
        FactoryBot.rewind_sequences
      end

      it 'can create sequential chapters' do
        book = create(:book)
        chapters = create_list(:chapter, 3, :sequential, book: book)
        expect(chapters.map(&:number)).to eq([1, 2, 3])
      end
    end
  end

  describe 'scopes' do
    let(:book) { create(:book) }
    let!(:rendered_chapter) { create(:chapter, :rendered, book: book, number: 1) }
    let!(:unrendered_chapter) { create(:chapter, :unrendered, book: book, number: 2) }

    describe '.rendered' do
      it 'returns only chapters with content' do
        expect(described_class.rendered).to contain_exactly(rendered_chapter)
      end
    end

    describe '.unrendered' do
      it 'returns only chapters without content' do
        expect(described_class.unrendered).to contain_exactly(unrendered_chapter)
      end
    end
  end

  describe 'content' do
    it 'allows content to be nil' do
      chapter = build(:chapter, content: nil)
      expect(chapter).to be_valid
      expect { chapter.save! }.not_to raise_error
      expect(chapter.content).to be_nil
    end
  end
end
