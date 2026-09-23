class GenerateBookPlotJob < MetaJob
  self.json_request = true
  self.json_schema = {
    type: "object",
    properties: {
      chapters: {
        type: "array",
        items: {
          type: "object",
          properties: {
            number: { type: "integer" },
            name: { type: "string" },
            outline: { type: "string" }
          },
          required: %w[number name outline],
          additionalProperties: false
        }
      }
    },
    required: ["chapters"],
    additionalProperties: false
  }

  def perform(component)
    @component = component
    @component.update(plot: nil)
    super()
  end

  private

  def prepare_component
    @component.update(pending: true)
    broadcast_component_update(@component)
    broadcast_action_buttons_update(@component)
  end

  def update_component(response)
    data = parse_content(response)
    
    # Update the book with the plot
    @component.update(
      pending: false
    )

    # Delete existing chapters if any
    @component.chapters.destroy_all
    
    # Create new chapters
    data["chapters"].each do |chapter|
      @component.chapters.create!(
        number: chapter["number"],
        name: chapter["name"],
        outline: chapter["outline"]
      )
    end

    # Broadcast updates to both prompt and action buttons
    broadcast_component_update(@component)
    broadcast_action_buttons_update(@component)
  end

  def broadcast_action_buttons_update(component)
    Turbo::StreamsChannel.broadcast_update_to(
      "#{component.class.name.underscore}_#{component.id}",
      target: "book_#{component.id}_action_buttons",
      partial: "books/action_buttons",
      locals: { component: component }
    )
  end

  def system_role
    <<~SYSTEM_ROLE
      You are a college level english teacher. Analyze the following JSON Object and create a detailed plot outline for a book.
      The plot should be consistent with:
      - The writing style specified
      - The narrative perspective
      - The narrative structure
      - The moral of the story
      - The characters' roles (protagonist, antagonists, other characters)
      - The characters' established traits and backstories
      
      Return a JSON object with:
      "chapters": An array of chapters where each chapter has:
         - "number": integer (sequential starting from 1)
         - "name": string (descriptive chapter title)
         - "outline": string (detailed chapter outline)

      Guidelines for chapters:
      - Create a logical chapter structure that follows the plot progression
      - Each chapter should have a clear focus and purpose
      - Chapter names should be descriptive and engaging
      - Outlines should be detailed and align with the main plot
      - Maintain consistent narrative flow between chapters

      Focus on major plot points, character arcs, and how the story progresses through the narrative structure.
      DONT MAKE ANYTHING UP beyond what's provided in the input data.
      
      Example response format:
      {
        "chapters": [
          {
            "number": 1,
            "name": "The Beginning",
            "outline": "Detailed outline of chapter 1..."
          }
        ]
      }
    SYSTEM_ROLE
  end

  def user_content
    @component.to_json
  end
end 