class WriteSceneSummaryJob < MetaJob
  self.max_retries = 3
  self.json_request = true
  self.json_schema = {
    type: "object",
    properties: {
      summary: { type: "string" }
    },
    required: ["summary"],
    additionalProperties: false
  }

  def perform(scene_id)
    @component = Scene.find(scene_id)
    @chapter = @component.chapter
    @book = @chapter.book
    
    super()
    
    summary_response = send_chat_request
    scene_summary = parse_content(summary_response)['summary']
    
    @component.update!(summary: scene_summary)
  end

  private

  def prepare_component
  end

  def update_component(response)
  end

  def system_role
    <<~SYSTEM_ROLE
      You are a professional editor. Your task is to create a concise 1-sentence summary of the provided scene video generation prompt.
      The summary should capture the core visual action and setting of the scene.

      You must respond with a valid JSON object in this exact format:
      {
        "summary": "the scene summary text"
      }
    SYSTEM_ROLE
  end

  def user_content
    @component.content
  end
end
