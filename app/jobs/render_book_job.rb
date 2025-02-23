class RenderBookJob < ApplicationJob
  def perform(book)
    @book = book
    begin
      start_rendering
      
      # First extract chapters
      ExtractChaptersJob.perform_now(@book)
      
      # Then write chapters
      WriteChaptersJob.perform_now(@book)
    ensure
      finish_rendering
    end
  end

  private

  def start_rendering
    @book.update(rendering: true)
    broadcast_book_update
  end

  def finish_rendering
    @book.update(rendering: false)
    broadcast_book_update
  end

  def broadcast_book_update
    computer_name = @book.class.name.underscore
    Turbo::StreamsChannel.broadcast_update_to(
      "#{computer_name}_#{@book.id}",
      target: "book_#{@book.id}_view_button",
      partial: "books/view_book_button",
      locals: { component: @book }
    )
  end
end 