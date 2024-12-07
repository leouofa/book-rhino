class GenerateCharacterPromptJob < MetaJob
  def perform(component)
    @component = component
    super()
  end

  private

  def system_role
    <<~SYSTEM_ROLE
      You are a college level english teacher. Analyze the following JSON Object and create a 3 paragraph character description to be given to an LLM. Don't mention JSON object. DONT MAKE ANYTHING UP.
    SYSTEM_ROLE
  end

  def user_content
    @component.to_json
  end
end
