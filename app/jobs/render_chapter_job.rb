class RenderChapterJob < ApplicationJob
  def perform(chapter)
    @chapter = chapter
    begin
      start_rendering

      prev = @chapter.previous_chapter
      WriteChapterContentJob.perform_now(@chapter.id, prev&.id)
    ensure
      finish_rendering
    end
  end

  private

  def start_rendering
    @chapter.update(rendering: true)
    broadcast_action_buttons_update
  end

  def finish_rendering
    @chapter.reload
    @chapter.update(rendering: false)
    broadcast_action_buttons_update
    broadcast_content_update
  end

  def broadcast_action_buttons_update
    Turbo::StreamsChannel.broadcast_update_to(
      "chapter_#{@chapter.id}",
      target: "chapter_#{@chapter.id}_action_buttons",
      partial: "chapters/action_buttons",
      locals: { component: @chapter, parent: @chapter.book }
    )
  end

  def broadcast_content_update
    Turbo::StreamsChannel.broadcast_update_to(
      "chapter_#{@chapter.id}",
      target: "chapter_#{@chapter.id}_content",
      partial: "chapters/chapter_content",
      locals: { component: @chapter }
    )
  end
end
