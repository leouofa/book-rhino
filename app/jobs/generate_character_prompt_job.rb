class GenerateCharacterPromptJob < ApplicationJob
  queue_as :default

  def perform(character)
    @client = OpenAI::Client.new

    system_role = <<~SYSTEM_ROLE
      You are a college level english teacher. Analyze the following JSON Object and create a 2 pargraph character description for ChatGPT. DONT MAKE ANYTHING UP.
    SYSTEM_ROLE

    messages = [
      { role: "system", content: system_role },
      { role: "user", content: character.to_json }
    ]

    sleep(0.5)

    character.update(pending: true)
    broadcast_character_update(character)

    sleep(10)

    response = chat(messages:)

    character.update(prompt: response["choices"][0]["message"]["content"], pending: false)

    broadcast_character_update(character)
  end

  private

  def chat(messages:)
    @client.chat(
      parameters: {
        model: ENV['OPENAI_GPT_MODEL'], # Required.
        messages:,
        temperature: 0.7
      }
    )
  end

  def broadcast_character_update(character)
    # This broadcasts to the specific Turbo Stream channel for the writing style
    Turbo::StreamsChannel.broadcast_update_to(
      "character_#{character.id}", # unique identifier for the writing style
      target: "character_#{character.id}_prompt", # the DOM ID where the prompt will be inserted
      partial: "characters/prompt", # partial view to render the updated content
      locals: { character: }
    )
  end
end
