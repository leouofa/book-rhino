class IterateOnCharacterPromptJob < ApplicationJob
  queue_as :default

  def perform(component, message)
    @client = OpenAI::Client.new

    system_role = <<~SYSTEM_ROLE
      You are a college level english teacher.
      You will be provided with a character description for ChatGPT and
      a request asking to modify it. Return only the character description.
    SYSTEM_ROLE

    messages = [
      { role: "system", content: system_role },
      { role: "user", content: "Character Description:\n#{component.prompt}\n--------\nRequest:\n#{message}" }
    ]

    sleep(0.1)

    component.update(pending: true)
    broadcast_component_update(component)

    sleep(3)

    response = chat(messages:)

    component.update(prompt: response["choices"][0]["message"]["content"], pending: false)

    broadcast_component_update(component)
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

  def broadcast_component_update(component)
    component_name = component.class.name.underscore

    Turbo::StreamsChannel.broadcast_update_to(
      "#{component_name}_#{component.id}", # unique identifier for the component
      target: "#{component_name}_#{component.id}_prompt", # the DOM ID where the prompt will be inserted
      partial: "#{component_name.pluralize}/prompt", # partial view to render the updated content
      locals: { component:, computer_name: component_name }
    )
  end
end
