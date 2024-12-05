class MergeCharacterPromptsJob < MetaJob
  def perform(component, version_to_merge)
    @component = component
    @version_to_merge = version_to_merge

    super()
  end

  private

  def system_role
    <<~SYSTEM_ROLE
      You are a college level english teacher.
      You will be provided with two character descriptions given to an LLM.
      Your task is to join the two character descriptions and factor out commonalities, merging them into a cohesive, unified character description.
      Return only the character description.
      DONT MAKE ANYTHING UP.
    SYSTEM_ROLE
  end

  def user_content
    "description_1:\n#{@component.prompt}\n--------\n#description_2:\n#{@version_to_merge.prompt}"
  end
end
