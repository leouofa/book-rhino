class RenderBookJob < ApplicationJob
  def perform(book)
    @book = book
    begin
      start_rendering
      
      # Then write chapters
      WriteChaptersJob.perform_now(@book)
    ensure
      finish_rendering
    end
  end

  private

  def start_rendering
    @book.update(rendering: true)
    broadcast_updates
  end

  def finish_rendering
    @book.update(rendering: false)
    broadcast_updates
  end

  def broadcast_updates
    broadcast_view_button_update
    broadcast_action_buttons_update
  end

  def broadcast_view_button_update
    computer_name = @book.class.name.underscore
    Turbo::StreamsChannel.broadcast_update_to(
      "#{computer_name}_#{@book.id}",
      target: "book_#{@book.id}_view_button",
      partial: "books/view_book_button",
      locals: { component: @book }
    )
  end

  def broadcast_action_buttons_update
    computer_name = @book.class.name.underscore
    Turbo::StreamsChannel.broadcast_update_to(
      "#{computer_name}_#{@book.id}",
      target: "book_#{@book.id}_action_buttons",
      partial: "books/action_buttons",
      locals: { component: @book }
    )
  end
end 