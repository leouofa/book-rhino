require 'rails_helper'

RSpec.describe Text, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:corpus) }
  end

  describe 'associations' do
    it { should belong_to(:writing_style) }
  end

  describe 'callbacks' do
    it 'enqueues writing style generation job after create' do
      text = build(:text)
      expect { text.save }.to have_enqueued_job(GenerateWritingStyleJob)
        .with(text.writing_style)
    end

    it 'enqueues writing style generation job after update' do
      text = create(:text)
      expect { text.update(corpus: 'New text') }.to have_enqueued_job(GenerateWritingStyleJob)
        .with(text.writing_style)
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:text)).to be_valid
    end
  end
end
