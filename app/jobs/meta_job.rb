class MetaJob < ApplicationJob
  queue_as :default

  class_attribute :max_retries, default: 0 # Default to disabled
  class_attribute :model # Default to nil (falls back to ENV['GEMINI_MODEL'])
  class_attribute :json_request, default: false # Default to no JSON response format
  class_attribute :json_schema # JSON Schema hash for structured output (Gemini 2.5+)

  def perform(...)
    prepare_component
    response = send_chat_request
    update_component(response)
  end

  private

  def prepare_component
    @component.update(pending: true)
    broadcast_component_update(@component)
  end

  def send_chat_request
    retry_on_failure { chat }
  end

  def update_component(response)
    @component.update(
      prompt: response_content(response),
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

  def chat
    chat = RubyLLM.chat(model: model_name)
                  .with_instructions(system_role)
                  .with_temperature(0.7)

    chat = chat.with_schema(self.class.json_schema) if self.class.json_request

    chat.ask(user_content)
  end

  def model_name
    self.class.model || ENV['GEMINI_MODEL'] || 'gemini-3.5-flash'
  end

  def response_content(response)
    content = response.content
    content.is_a?(String) ? content : JSON.generate(content)
  end

  def parse_content(response)
    content = response.content
    content.is_a?(String) ? JSON.parse(content) : content
  end

  def retry_on_failure
    return yield if self.class.max_retries.zero?

    attempts = 0
    begin
      yield
    rescue RubyLLM::Error => e
      attempts += 1
      raise e unless retryable?(e) && attempts < self.class.max_retries

      sleep(1)
      retry
    end
  end

  def retryable?(error)
    [
      RubyLLM::BadRequestError,
      RubyLLM::RateLimitError,
      RubyLLM::OverloadedError,
      RubyLLM::ServerError,
      RubyLLM::ServiceUnavailableError
    ].any? { |klass| error.is_a?(klass) }
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
