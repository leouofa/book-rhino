class WriteSceneContentJob < MetaJob
  self.max_retries = 3
  self.disable_thinking = true

  SHOT_TYPES = [
    "Establishing Shot",
    "Wide Shot",
    "Full Shot",
    "Medium Shot",
    "Medium Close Up",
    "Close Up",
    "Extreme Close Up",
    "Over the Shoulder",
    "Point of View (POV)",
    "High Angle",
    "Low Angle",
    "Drone Shot"
  ].freeze

  def perform(scene_id, shot_type = nil)
    @shot_type = shot_type || SHOT_TYPES.sample
    @component = Scene.find(scene_id)
    @chapter = @component.chapter
    @book = @chapter.book
    
    super()
    
    # response = send_chat_request
    # scene_content = response_content(response)
    # @component.update!(content: scene_content)
    
    WriteSceneSummaryJob.perform_later(@component.id)
  end

  private

  def prepare_component
  end

  def update_component(response)
    @component.update!(content: response_content(response))
  end

  def system_role
    <<~SYSTEM_ROLE
      You are an expert prompt engineer for video generation models.
      Your task is to write detailed instructions for the video model to move the camera and shoot a scene, based on the provided scene outline.
      
      CRITICAL INSTRUCTION: You MUST describe a SINGLE, CONTINUOUS shot without any camera cuts.
      
      The prompt should include:
      - Camera movement (e.g., pan, tilt, tracking shot)
      - Lighting and atmosphere
      - Subject actions and positioning
      - The framing must strictly be a: #{@shot_type}
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
