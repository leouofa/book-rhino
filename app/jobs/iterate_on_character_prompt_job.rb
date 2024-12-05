class IterateOnCharacterPromptJob < MetaJob
  def perform(component, message)
    @component = component
    @message = message

    super()
  end

  private

  def system_role
    <<~SYSTEM_ROLE
      You are a college level english teacher.
      You will be provided with a character description for ChatGPT and
      a request asking to modify it. Return only the character description.
    SYSTEM_ROLE
  end

  def user_content
    "Character Description:\n#{@component.prompt}\n--------\nRequest:\n#{@message}"
  end
end
