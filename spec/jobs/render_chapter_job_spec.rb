require 'rails_helper'

RSpec.describe RenderChapterJob, type: :job do
  let(:book) { create(:book) }
  let!(:chapter1) { create(:chapter, book: book, number: 1, content: 'Chapter 1 text') }
  let!(:chapter2) { create(:chapter, book: book, number: 2, content: nil) }

  describe '#perform' do
    it 'calls WriteChapterContentJob with chapter id and previous chapter id' do
      expect(WriteChapterContentJob).to receive(:perform_now).with(chapter2.id, chapter1.id)
      allow(Turbo::StreamsChannel).to receive(:broadcast_update_to)

      described_class.new.perform(chapter2)
    end

    it 'calls WriteChapterContentJob with nil previous_chapter_id for chapter 1' do
      expect(WriteChapterContentJob).to receive(:perform_now).with(chapter1.id, nil)
      allow(Turbo::StreamsChannel).to receive(:broadcast_update_to)

      described_class.new.perform(chapter1)
    end

    it 'broadcasts action buttons and content updates' do
      allow(WriteChapterContentJob).to receive(:perform_now)

      expect(Turbo::StreamsChannel).to receive(:broadcast_update_to).with(
        "chapter_#{chapter2.id}",
        target: "chapter_#{chapter2.id}_action_buttons",
        partial: "chapters/action_buttons",
        locals: { component: chapter2, parent: book }
      ).twice

      expect(Turbo::StreamsChannel).to receive(:broadcast_update_to).with(
        "chapter_#{chapter2.id}",
        target: "chapter_#{chapter2.id}_content",
        partial: "chapters/chapter_content",
        locals: { component: chapter2 }
      ).once

      described_class.new.perform(chapter2)
    end

    it 'resets rendering to false even if WriteChapterContentJob raises an error' do
      allow(WriteChapterContentJob).to receive(:perform_now).and_raise(StandardError, 'API failure')
      allow(Turbo::StreamsChannel).to receive(:broadcast_update_to)

      expect {
        described_class.new.perform(chapter2)
      }.to raise_error(StandardError, 'API failure')

      expect(chapter2.reload.rendering).to be(false)
    end
  end
end
