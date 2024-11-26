class IterateOnWritingStyleJob < ApplicationJob
  queue_as :default

  def perform(writing_style, message)
    writing_style_json = JSON.parse(writing_style.prompt)

    @client = OpenAI::Client.new

    system_role = <<~SYSTEM_ROLE
        You are a college level english teacher. 
        You will be provided with a list(containing a set of instructions describing a writing style) and
        a request asking to modify it. Complete the request and return the new list with numbers 1 through n in JSON format
    SYSTEM_ROLE

    messages = [
      { role: "system", content: system_role },
      { role: "user", content: "Writing Style:\n#{writing_style_json}\n--------\nRequest:\n#{message}" }
    ]

    sleep(0.1)


    writing_style.update(pending: true)
    broadcast_writing_style_update(writing_style)

    sleep(3)

    response = retry_on_failure { chat(messages:) }

    new_prompt = response["choices"][0]["message"]["content"]

    writing_style.update(prompt: new_prompt, pending: false)

    broadcast_writing_style_update(writing_style)

  end

  def chat(messages:)
    @client.chat(
      parameters: {
        model: ENV['OPENAI_SMART_MODEL'], # Required.
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
      yield # Execute the block passed to retry_on_failure
    rescue Faraday::BadRequestError => e
      attempts += 1
      if attempts < MAX_RETRIES
        sleep(5) # Wait before retrying
        retry # Retry the block
      else
        raise e # Reraise the exception after max retries
      end
    end
  end

  def broadcast_writing_style_update(writing_style)
    Turbo::StreamsChannel.broadcast_update_to(
      "writing_style_#{writing_style.id}",
      target: "writing_style_#{writing_style.id}_prompt",
      partial: "writing_styles/prompt",
      locals: { component: writing_style }
    )
  end
end
