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
      You are a professional screenwriter and director's assistant.
      Your task is to take a chapter's content and divide it into exactly #{@component.scene_count} scene outlines.
      Each scene outline should capture a discrete chunk of the narrative, focusing on physical actions, dialogue beats, and setting shifts that would make a good continuous shot or coherent scene in a video generation model.
      
      You must return exactly #{@component.scene_count} scenes.
      
      You must respond with a valid JSON object in this exact format:
      {
        "scenes": [
          { "outline": "the outline for scene 1" },
          { "outline": "the outline for scene 2" }
        ]
      }
    SYSTEM_ROLE
  end

  def user_content
    prompt = {
      book_context: @book.as_json,
      chapter_number: @component.number,
      chapter_name: @component.name,
      chapter_content: @component.content,
      target_scene_count: @component.scene_count
    }
    
    prompt.to_json
  end
end
