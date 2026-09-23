class WriteSceneContentJob < MetaJob
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

  def perform(scene_id)
    @component = Scene.find(scene_id)
    @chapter = @component.chapter
    @book = @chapter.book
    
    super()
    
    content_response = send_chat_request
    scene_content = parse_content(content_response)['content']
    
    @component.update!(content: scene_content)
    
    WriteSceneSummaryJob.perform_later(@component.id)
  end

  private

  def prepare_component
  end

  def update_component(response)
  end

  def system_role
    <<~SYSTEM_ROLE
      You are an expert prompt engineer for video generation models (like Sora, Runway, etc).
      Your task is to write detailed instructions for the video model to move the camera and shoot a scene, based on the provided scene outline.
      
      The prompt should include:
      - Camera movement (e.g., pan, tilt, tracking shot, drone shot)
      - Lighting and atmosphere
      - Subject actions and positioning
      - Framing (e.g., wide shot, close up)
      
      You must respond with a valid JSON object in this exact format:
      {
        "content": "your video generation prompt here"
      }
    SYSTEM_ROLE
  end

  def user_content
    prompt = {
      book_context: @book.as_json,
      chapter_context: {
        number: @chapter.number,
        name: @chapter.name
      },
      scene_number: @component.number,
      scene_outline: @component.outline
    }

    prompt.to_json
  end
end
