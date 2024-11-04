class GenerateCharacterPromptJob < ApplicationJob
  queue_as :default

  def perform(component)
    @client = OpenAI::Client.new

    system_role = <<~SYSTEM_ROLE
      You are a college level english teacher. Analyze the following JSON Object and create a 2 pargraph character description for ChatGPT. DONT MAKE ANYTHING UP.
    SYSTEM_ROLE

    messages = [
      { role: "system", content: system_role },
      { role: "user", content: component.to_json }
    ]

    sleep(0.5)

    component.update(pending: true)
    broadcast_component_update(component)

    sleep(10)

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
