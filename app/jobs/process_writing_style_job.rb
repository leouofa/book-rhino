class ProcessWritingStyleJob < MetaJob
  def perform(component)
    @component = component

    sleep(0.5)
    super()
    sleep(10)
  end

  private

  def system_role
    <<~SYSTEM_ROLE
      You are a college level english teacher. Analyze the following writing style and produce a set of instructions for ChatGPT in order to reproduce this writing style. Return ONLY the list with numbers 1 through n in JSON format. DONT MAKE ANYTHING UP.
    SYSTEM_ROLE
  end

  def user_content
    question = ""
    @component.texts.each do |text|
      question.concat "``````", "Text Name: #{text.name}, Corpus: #{text.corpus}", "``````"
    end
    question
  end

  def chat(messages:)
    @client.chat(
      parameters: {
        model: ENV['OPENAI_GPT_MODEL'],
        messages:,
        temperature: 0.7,
        response_format: { type: "json_object" }
      }
    )
  end
end
