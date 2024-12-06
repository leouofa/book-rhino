class GenerateLocationPromptJob < MetaJob
  queue_as :default

  def perform(component)
    @component = component
    super()
  end

  private

  def system_role
    <<~SYSTEM_ROLE
      You are a college level english teacher. Analyze the following JSON Object and create a 3 paragraph location description to be given to an LLM. DONT MAKE ANYTHING UP.
    SYSTEM_ROLE
  end

  def user_content
    @component.location_details.to_json
  end
end
