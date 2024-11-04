class NarrativeStructuresController < MetaController
  def component_name
    'Narrative Structures'
  end

  def component_class
    'NarrativeStructure'.constantize
  end

  def sort_direction
    :asc
  end
end
