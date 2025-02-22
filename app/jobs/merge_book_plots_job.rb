class MergeBookPlotsJob < MetaJob
  def perform(component, version_to_merge)
    @component = component
    @version_to_merge = version_to_merge

    super()
  end

  private

  def update_component(response)
    @component.update(
      plot: response["choices"][0]["message"]["content"],
      pending: false
    )
    broadcast_component_update(@component)
  end

  def system_role
    <<~SYSTEM_ROLE
      You are a college level english teacher.
      You will be provided with two book plot outlines.
      Your task is to join the two plot outlines and factor out commonalities,
      merging them into a cohesive, unified plot outline that maintains consistency with:
      - The writing style
      - The narrative perspective
      - The narrative structure
      - The moral of the story
      - The characters' roles and traits
      
      Return only the merged plot outline.
      DONT MAKE ANYTHING UP beyond what's provided in the original plots.
    SYSTEM_ROLE
  end

  def user_content
    "plot_1:\n#{@component.plot}\n--------\nplot_2:\n#{@version_to_merge.plot}"
  end
end 