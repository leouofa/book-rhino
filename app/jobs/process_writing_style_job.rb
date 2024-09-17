class ProcessWritingStyleJob < ApplicationJob
  queue_as :default

  def perform(writing_style)
    question = ""

    writing_style.texts.each do |text|
      question.concat "``````","Text Name: #{text.name}, Corpus: #{text.corpus}", "``````"
    end

    @client = OpenAI::Client.new

    system_role = <<~SYSTEM_ROLE
        You are a college level english teacher. Analyze the following writing style and produce a set of instructions for ChatGPT in order to reproduce this writing style. Return ONLY the list with numbers 1 through n in JSON format. DONT MAKE ANYTHING UP.
    SYSTEM_ROLE

    messages = [
      { role: "system", content: system_role },
      { role: "user", content: question }
    ]

    writing_style. update(pending: true)
    broadcast_writing_style_update(writing_style)

    sleep(10)

    response = chat(messages:)

    writing_style.update(prompt: response["choices"][0]["message"]["content"], pending: false)

    # Broadcasting Turbo Stream after updating the writing style
    broadcast_writing_style_update(writing_style)
  end

  def chat(messages:)
    @client.chat(
      parameters: {
        model: ENV['OPENAI_GPT_MODEL'], # Required.
        messages:,
        temperature: 0.7,
        response_format: { type: "json_object" }
      }
    )
  end

  private

  def broadcast_writing_style_update(writing_style)
    # This broadcasts to the specific Turbo Stream channel for the writing style
    Turbo::StreamsChannel.broadcast_update_to(
      "writing_style_#{writing_style.id}", # unique identifier for the writing style
      target: "writing_style_#{writing_style.id}_prompt", # the DOM ID where the prompt will be inserted
      partial: "texts/prompt", # partial view to render the updated content
      locals: { writing_style: writing_style}
    )
  end
end
