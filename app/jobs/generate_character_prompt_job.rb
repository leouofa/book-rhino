class GenerateCharacterPromptJob < MetaJob
  def perform(component)
    @component = component

    sleep(0.5)
    super()
    sleep(10)
  end

  private

  def system_role
    <<~SYSTEM_ROLE
      You are a college level english teacher. Analyze the following JSON Object and create a 2 pargraph character description for ChatGPT. DONT MAKE ANYTHING UP.
    SYSTEM_ROLE
  end

  def user_content
    @component.to_json
  end
end
