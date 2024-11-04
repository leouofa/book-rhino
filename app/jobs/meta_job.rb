class MetaJob < ApplicationJob
  queue_as :default

  def perform(...)
      initialize_client
      prepare_component
      response = send_chat_request
      update_component(response)
    end

    private

    def initialize_client
      @client = OpenAI::Client.new
    end

    def prepare_component
      @component.update(pending: true)
      broadcast_component_update(@component)
    end

    def send_chat_request
      chat(messages: build_messages)
    end

    def update_component(response)
      @component.update(
        prompt: response["choices"][0]["message"]["content"],
        pending: false
      )
      broadcast_component_update(@component)
    end

    def system_role
      raise NotImplementedError, "#{self.class} must implement system_role"
    end

    def user_content
      raise NotImplementedError, "#{self.class} must implement user_content"
    end

    def build_messages
      [
        { role: "system", content: system_role },
        { role: "user", content: user_content }
      ]
    end

    def chat(messages:)
      @client.chat(
        parameters: {
          model: ENV['OPENAI_GPT_MODEL'],
          messages:,
          temperature: 0.7
        }
      )
    end

    def broadcast_component_update(component)
      component_name = component.class.name.underscore

      Turbo::StreamsChannel.broadcast_update_to(
        "#{component_name}_#{component.id}",
        target: "#{component_name}_#{component.id}_prompt",
        partial: "#{component_name.pluralize}/prompt",
        locals: { component:, computer_name: component_name }
      )
    end
end
