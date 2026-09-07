class WriteChapterContentJob < MetaJob
  self.max_retries = 3
  self.disable_thinking = true
  self.json_request = true
  self.json_schema = {
    type: "object",
    properties: {
      content: { type: "string" }
    },
    required: ["content"],
    additionalProperties: false
  }
  WORDS_PER_PAGE = 250

  def perform(chapter_id, previous_chapter_id)
    @component = Chapter.find(chapter_id)
    @previous_chapter = Chapter.find(previous_chapter_id) if previous_chapter_id
    @book = @component.book
    @pages_per_chapter = calculate_pages_per_chapter
    @target_words = @pages_per_chapter * WORDS_PER_PAGE
    
    content_response = send_chat_request
    chapter_content = parse_content(content_response)['content']
    
    @component.update!(content: chapter_content)
    
    WriteChapterSummaryJob.perform_now(@component.id)
  end

  private

  def prepare_component
    # Status tracking happens at Book level, not Chapter level
  end

  def update_component(response)
    # Component updates are handled in perform
  end

  def system_role
    <<~SYSTEM_ROLE
      You are a professional writer. Your task is to write a chapter for a book based on:
      1. The book's overall context (plot, style, perspective, etc.)
      2. The specific chapter's plot summary
      3. The previous chapter's content (if provided)
      4. The target length in words (VERY IMPORTANT)

      LENGTH REQUIREMENT (STRICT):
      - Target word count: #{@target_words} words
      - This is based on #{@pages_per_chapter} pages at #{WORDS_PER_PAGE} words per page
      - Your response must be within 20% of this target length
      - Current responses are too short - please ensure you meet the length requirement

      Write the chapter maintaining:
      - The book's established writing style
      - The specified narrative perspective
      - Consistency with the plot summary
      - Proper flow from the previous chapter (if provided)
      - Required length (#{@target_words} words)

      You must respond with a valid JSON object in this exact format:
      {
        "content": "the complete chapter text"
      }

      Guidelines:
      - You MUST write #{@target_words} words (±20%)
      - Maintain consistent tone and style throughout
      - Ensure narrative flows naturally from previous chapter
      - Include proper paragraph breaks and dialogue formatting
      - Stay true to the plot summary while adding appropriate detail
    SYSTEM_ROLE
  end

  def user_content
    prompt = {
      book_context: @book.as_json,
      chapter_number: @component.number,
      chapter_name: @component.name,
      plot_summary: @component.plot_summary,
      target_words: @target_words,
      target_pages: @pages_per_chapter,
      words_per_page: WORDS_PER_PAGE,
      length_requirement: "IMPORTANT: Write exactly #{@target_words} words (±20%)"
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