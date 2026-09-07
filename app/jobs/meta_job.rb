class MetaJob < ApplicationJob
  include JsonParsing

  queue_as :default

  class_attribute :max_retries, default: 0 # Default to disabled
  class_attribute :model # Default to nil (falls back to ENV['LLM_MODEL'] or provider-specific env)
  class_attribute :json_request, default: false # Default to no JSON response format
  class_attribute :json_schema # JSON Schema hash for structured output
  class_attribute :disable_thinking, default: false # Sends think: false for providers that support it

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
    chat = RubyLLM.chat(model: model_name, provider: :ollama)
                  .with_instructions(system_role)
                  .with_temperature(0.7)

    params = {}
    params[:format] = self.class.json_schema if self.class.json_request
    params[:think] = false if self.class.disable_thinking
    chat = chat.with_params(**params) unless params.empty?

    chat.ask(user_content)
  end

  def model_name
    self.class.model || ENV['LLM_MODEL'] || ENV['OLLAMA_MODEL'] || 'Qwen3.6-35B-A3B-FP8'
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
