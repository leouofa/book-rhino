class IterateOnWritingStyleJob < MetaJob
  MAX_RETRIES = 3

  def perform(component, message)
    @component = component
    @message = message
    @writing_style_json = JSON.parse(component.prompt)

    super()
  end

  private

  def system_role
    <<~SYSTEM_ROLE
      You are a college level english teacher.
      You will be provided with a list(containing a set of instructions describing a writing style) and
      a request asking to modify it. Complete the request and return the new list with numbers 1 through n in JSON format
    SYSTEM_ROLE
  end

  def user_content
    "Writing Style:\n#{@writing_style_json}\n--------\nRequest:\n#{@message}"
  end

  def send_chat_request
    retry_on_failure { chat(messages: build_messages) }
  end

  def chat(messages:)
    @client.chat(
      parameters: {
        model: ENV['OPENAI_SMART_MODEL'],
        messages:,
        temperature: 0.7,
        response_format: { type: "json_object" }
      }
    )
  end

  private

  def retry_on_failure
    attempts = 0

    begin
      yield
    rescue Faraday::BadRequestError => e
      attempts += 1
      if attempts < MAX_RETRIES
        sleep(5)
        retry
      else
        raise e
      end
    end
  end
end
