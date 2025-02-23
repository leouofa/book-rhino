class RenderBookJob < ApplicationJob
  def perform(book)
    @book = book
    @book.update(pending: true)
    
    # First extract chapters
    ExtractChaptersJob.perform_now(@book)
    
    # Then write chapters
    WriteChaptersJob.perform_now(@book)
  end
end 