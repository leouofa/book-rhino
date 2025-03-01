class MergeWritingStylesJob < MetaJob
  self.max_retries = 3
  self.openai_model = ENV['OPENAI_MODEL']
  self.json_request = true

  def perform(component, version_to_merge)
    @component = component
    @version_to_merge = version_to_merge
    @json_1 = JSON.parse(component.prompt)
    @json_2 = JSON.parse(version_to_merge.prompt)

    super()
  end

  private

  def system_role
    <<~SYSTEM_ROLE
      You are an expert in analyzing and combining writing styles.
      You will be provided with two sets of instructions in forms of lists.
      Your task is to join the two lists and factor out commonalities, merging them into a cohesive, unified set of instructions.
      Return ONLY the merged list with numbers 1 through n in JSON format.
      DONT MAKE ANYTHING UP.
    SYSTEM_ROLE
  end

  def user_content
    "#{@json_1}\n--------\n#{@json_2}"
  end
end
