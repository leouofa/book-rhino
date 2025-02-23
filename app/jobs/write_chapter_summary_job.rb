class WriteChapterSummaryJob < MetaJob
  self.max_retries = 3
  self.openai_model = ENV['OPENAI_MODEL']

  def perform(chapter_id)
    @component = Chapter.find(chapter_id)
    @book = @component.book
    
    super()
    
    summary_response = send_chat_request
    chapter_summary = JSON.parse(summary_response['choices'][0]['message']['content'])['summary']
    
    @component.update!(summary: chapter_summary)
    
    # If this is the last chapter, mark the book as not pending
    if @component.number == @book.chapter_count
      @book.update(pending: false)
    end
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
      You are a professional editor. Your task is to create a concise summary of the provided chapter content.
      The summary should:
      - Capture the key events and developments
      - Highlight important character moments
      - Note any significant plot developments
      - Be approximately 2-3 paragraphs in length

      You must respond with a valid JSON object in this exact format:
      {
        "summary": "the chapter summary text"
      }

      Guidelines:
      - Response must be valid JSON
      - Do not include markdown formatting
      - Keep the summary concise but informative
    SYSTEM_ROLE
  end

  def user_content
    @component.content
  end
end 