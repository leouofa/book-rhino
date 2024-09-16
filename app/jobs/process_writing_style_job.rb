class ProcessWritingStyleJob < ApplicationJob
  queue_as :default

  def perform(writing_style)
    question = ""

    writing_style.texts.each do |text|
      question.concat "``````","Text Name: #{text.name}, Corpus: #{text.corpus}", "``````"
    end

    @client = OpenAI::Client.new

    system_role = <<~SYSTEM_ROLE
        You are a college level english teacher. Analyze the following writing style and produce a set of instructions for ChatGPT in order to reproduce this writing style. Return ONLY the list with numbers 1 through n. DONT MAKE ANYTHING UP.
    SYSTEM_ROLE

    messages = [
      { role: "system", content: system_role },
      { role: "user", content: question }
    ]

    response = chat(messages:)

    writing_style.update(prompt: response["choices"][0]["message"]["content"])
  end

  def chat(messages:)
    @client.chat(
      parameters: {
        model: ENV['OPENAI_GPT_MODEL'], # Required.
        messages:,
        temperature: 0.7
      }
    )
  end
end
