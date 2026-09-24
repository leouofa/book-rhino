class WriteScenesJob < MetaJob
  self.max_retries = 3
  self.disable_thinking = true
  self.json_request = true
  self.json_schema = {
    type: "object",
    properties: {
      scenes: {
        type: "array",
        items: {
          type: "object",
          properties: {
            outline: { type: "string" }
          },
          required: ["outline"],
          additionalProperties: false
        }
      }
    },
    required: ["scenes"],
    additionalProperties: false
  }

  def perform(chapter_id)
    @component = Chapter.find(chapter_id)
    @book = @component.book
    
    super()
    
    response = send_chat_request
    parsed_response = parse_content(response)
    
    ActiveRecord::Base.transaction do
      @component.scenes.destroy_all
      parsed_response['scenes'].each_with_index do |scene_data, index|
        scene = @component.scenes.create!(
          number: index + 1,
          outline: scene_data['outline']
        )
        WriteSceneContentJob.perform_later(scene.id)
      end
    end
  end

  private

  def prepare_component
  end

  def update_component(response)
  end

  def system_role
    <<~SYSTEM_ROLE
      You are an expert visual storyteller and director's assistant.
      Your task is to adapt a chapter's text into exactly #{@component.scene_count} distinct visual scene outlines. 
      These outlines will be fed into an AI video generation pipeline, which means they must be optimized for visual rendering, not theatrical acting.

      CRITICAL CONSTRAINTS FOR EACH OUTLINE:
      1. SHOW, DON'T TELL (NO DIALOGUE): AI video models do not generate audio or dialogue. You must translate any spoken words, internal monologues, or abstract concepts from the chapter into purely observable physical actions, facial expressions, and object interactions.
      2. THE 10-SECOND RULE: Each outline must describe a "micro-moment"—a single, continuous slice of time taking no more than 10 seconds. Do not summarize entire events, conversations, or include time jumps within a single outline.
      3. CONCRETE METAPHORS: If the chapter text is conceptual or non-fiction, you must invent a concrete, physical B-roll scenario that visually represents the concept (e.g., instead of "he learned a new skill," describe "close up of hands clumsily but determinedly assembling a complex mechanical part").
      4. SINGLE SHOT COMPATIBILITY: Ensure the action described in each outline can logically be captured in one continuous, unbroken camera shot.

      You must return exactly #{@component.scene_count} scenes.

      You must respond strictly with a valid JSON object in this exact format, with no markdown formatting outside the JSON:
      {
        "scenes": [
          { "outline": "Detailed description of the physical action, character blocking, setting, and mood for scene 1." },
          { "outline": "Detailed description of the physical action, character blocking, setting, and mood for scene 2." }
        ]
      }
    SYSTEM_ROLE
  end

  def user_content
    prompt = {
      book_context: @book.as_scene_json,
      chapter_number: @component.number,
      chapter_name: @component.name,
      chapter_content: @component.content,
      target_scene_count: @component.scene_count
    }
    
    prompt.to_json
  end
end
