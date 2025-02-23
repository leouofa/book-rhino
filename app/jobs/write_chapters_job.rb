class WriteChaptersJob < ApplicationJob
  def perform(book)
    @book = book
    @book.update(pending: true)
    
    previous_chapter_id = nil
    @book.chapters.order(:number).each do |chapter|
      WriteChapterContentJob.perform_now(chapter.id, previous_chapter_id)
      previous_chapter_id = chapter.id
    end
  end
end 