class MergeCharacterPromptsJob < ApplicationJob
  queue_as :default

  def perform(character, version_to_merge)
    prompt_1 = character.prompt
    prompt_2 = version_to_merge.prompt

    @client = OpenAI::Client.new

    system_role = <<~SYSTEM_ROLE
      You are a college level english teacher.
      You will be provided with two character descriptions for ChatGPT.
      Your task is to join the two character descriptions and factor out commonalities, merging them into a cohesive, unified character description.#{' '}
      Return only the character description.
      DONT MAKE ANYTHING UP.
    SYSTEM_ROLE

    messages = [
      { role: "system", content: system_role },
      { role: "user", content: "description_1:\n#{prompt_1}\n--------\n#description_2:\n#{prompt_2}" }
    ]

    sleep(0.5)

    character.update(pending: true)
    broadcast_character_update(character)

    sleep(3)

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
