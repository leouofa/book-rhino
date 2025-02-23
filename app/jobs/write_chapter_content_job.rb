class WriteChapterContentJob < MetaJob
  self.max_retries = 3
  self.openai_model = ENV['OPENAI_MODEL']

  def perform(chapter_id, previous_chapter_id)
    @component = Chapter.find(chapter_id)
    @previous_chapter = Chapter.find(previous_chapter_id) if previous_chapter_id
    @book = @component.book
    @pages_per_chapter = calculate_pages_per_chapter
    
    super()
    
    content_response = send_chat_request
    chapter_content = JSON.parse(content_response['choices'][0]['message']['content'])['content']
    
    @component.update!(content: chapter_content)
    
    WriteChapterSummaryJob.perform_later(@component.id)
  end

  private

  def prepare_component
    # Status tracking happens at Book level, not Chapter level
  end

  def update_component(response)
    # Component updates are handled in perform
  end

  def chat(messages:)
    @client.chat(
      parameters: {
        model: self.class.openai_model || ENV['OPENAI_MODEL'],
        messages:,
        temperature: 0.7,
        response_format: { type: 'json_object' }
      }
    )
  end

  def system_role
    <<~SYSTEM_ROLE
      You are a professional writer. Your task is to write a chapter for a book based on:
      1. The book's overall context (plot, style, perspective, etc.)
      2. The specific chapter's plot summary
      3. The previous chapter's content (if provided)
      4. The target length in pages

      Write the chapter maintaining:
      - The book's established writing style
      - The specified narrative perspective
      - Consistency with the plot summary
      - Proper flow from the previous chapter (if provided)
      - Appropriate length based on pages target

      You must respond with a valid JSON object in this exact format:
      {
        "content": "the complete chapter text"
      }

      Guidelines:
      - Each page should be approximately 250 words
      - Maintain consistent tone and style throughout
      - Ensure narrative flows naturally from previous chapter
      - Include proper paragraph breaks and dialogue formatting
      - Stay true to the plot summary while adding appropriate detail
      - Response must be valid JSON
    SYSTEM_ROLE
  end

  def user_content
    prompt = {
      book_context: @book.as_json,
      chapter_number: @component.number,
      chapter_name: @component.name,
      plot_summary: @component.plot_summary,
      target_pages: @pages_per_chapter
    }

    if @previous_chapter
      prompt[:previous_chapter] = {
        number: @previous_chapter.number,
        name: @previous_chapter.name,
        content: @previous_chapter.content
      }
    end

    prompt.to_json
  end

  def calculate_pages_per_chapter
    return 0 unless @book.pages && @book.chapter_count && @book.chapter_count > 0
    (@book.pages.to_f / @book.chapter_count).ceil
  end
end 