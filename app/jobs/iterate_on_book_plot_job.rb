class IterateOnBookPlotJob < MetaJob
  def perform(component, message)
    @component = component
    @message = message

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
      You are a college level english teacher.
      You will be provided with a book plot outline and a request to modify it.
      Modify the plot while maintaining consistency with:
      - The writing style
      - The narrative perspective
      - The narrative structure
      - The moral of the story
      - The characters' roles and traits
      
      Return only the modified plot outline.
      DONT MAKE ANYTHING UP beyond what's provided in the original plot.
    SYSTEM_ROLE
  end

  def user_content
    "Book Plot:\n#{@component.plot}\n--------\nRequest:\n#{@message}"
  end
end 