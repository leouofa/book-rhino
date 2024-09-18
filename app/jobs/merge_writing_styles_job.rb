class MergeWritingStylesJob < ApplicationJob
  queue_as :default

  MAX_RETRIES = 8

  def perform(writing_style, version_to_merge)
    json_1 = JSON.parse(writing_style.prompt)
    json_2 = JSON.parse(version_to_merge.prompt)

    @client = OpenAI::Client.new

    system_role = <<~SYSTEM_ROLE
        You are an expert in analyzing and combining writing styles. 
        You will be provided with two sets of instructions in forms of lists. 
        Your task is to join the two lists and factor out commonalities, merging them into a cohesive, unified set of instructions. 
        Return ONLY the merged list with numbers 1 through n in JSON format. 
        DONT MAKE ANYTHING UP.
    SYSTEM_ROLE

    messages = [
      { role: "system", content: system_role },
      { role: "user", content: "#{json_1}\n--------\n#{json_2}" }
    ]

    sleep(0.5)

    writing_style.update(pending: true)
    broadcast_writing_style_update(writing_style)

    sleep(10)

    # response = chat(messages:)
    response = retry_on_failure { chat(messages:) }

    merged_prompt = response["choices"][0]["message"]["content"]

    # Update the writing style with the merged result
    writing_style.update(prompt: merged_prompt, pending: false)

    # Broadcast the update
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
      partial: "texts/prompt",
      locals: { writing_style: writing_style }
    )
  end
end
