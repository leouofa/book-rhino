require 'rails_helper'

RSpec.describe ChaptersController, type: :controller do
  let(:user) { create(:user, has_access: true) }
  let(:book) { create(:book) }

  before do
    sign_in user
  end

  describe 'POST #render_chapter' do
    context 'when chapter can be rendered' do
      let!(:chapter1) { create(:chapter, book: book, number: 1) }

      it 'enqueues RenderChapterJob and marks chapter as rendering' do
        expect {
          post :render_chapter, params: { book_id: book.id, id: chapter1.id }
        }.to have_enqueued_job(RenderChapterJob).with(chapter1)

        expect(chapter1.reload.rendering).to be(true)
        expect(response).to redirect_to(book_chapter_path(book, chapter1))
        expect(flash[:notice]).to eq('Rendering chapter in progress...')
      end

      it 'responds with turbo_stream format' do
        post :render_chapter, params: { book_id: book.id, id: chapter1.id }, format: :turbo_stream
        expect(response.media_type).to eq('text/vnd.turbo-stream.html')
        expect(response).to render_template('chapters/render_chapter')
      end
    end

    context 'when chapter cannot be rendered because previous chapter is unrendered' do
      let!(:chapter1) { create(:chapter, :unrendered, book: book, number: 1) }
      let!(:chapter2) { create(:chapter, :unrendered, book: book, number: 2) }

      it 'does not enqueue RenderChapterJob and sets alert' do
        expect {
          post :render_chapter, params: { book_id: book.id, id: chapter2.id }
        }.not_to have_enqueued_job(RenderChapterJob)

        expect(chapter2.reload.rendering).to be(false)
        expect(response).to redirect_to(book_chapter_path(book, chapter2))
        expect(flash[:alert]).to eq('Previous chapter must be rendered first.')
      end
    end
  end
end
