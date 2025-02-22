class GenerateBookPlotJob < MetaJob
  self.openai_model = ENV['OPENAI_MODEL']

  def perform(component)
    @component = component
    super()
  end

  private

  def update_component(response)
    @component.update(
      plot: response["choices"][0]["message"]["content"],
      pending: false
    )
    broadcast_component_update(@component)
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
      
      Return a well-structured plot outline that could be used by a writer.
      Focus on major plot points, character arcs, and how the story progresses through the narrative structure.
      DONT MAKE ANYTHING UP beyond what's provided in the input data.
    SYSTEM_ROLE
  end

  def user_content
    @component.to_json
  end
end 