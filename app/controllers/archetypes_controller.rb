class ArchetypesController < MetaController
  def component_name
    'Archetypes'
  end

  def component_class
    'Archetype'.constantize
  end

  def sort_direction
    :asc
  end
end
