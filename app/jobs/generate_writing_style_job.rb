class GenerateWritingStyleJob < MetaJob
  self.json_request = true
  self.json_schema = {
    type: "array",
    items: { type: "string" }
  }

  def perform(component)
    @component = component

    super()
  end

  private

  def system_role
    <<~SYSTEM_ROLE
      You are a college level english teacher. Analyze the following writing style and produce a set of instructions for an AI writing assistant in order to reproduce this writing style. 
      Return ONLY the array of instructions.
    SYSTEM_ROLE
  end

  def user_content
    question = ""
    @component.texts.each do |text|
      question.concat "``````", "Text Name: #{text.name}, Corpus: #{text.corpus}", "``````"
    end
    question
  end
end
