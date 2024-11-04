class PerspectivesController < MetaController
  def component_name
    'Perspectives'
  end

  def component_class
    'Perspective'.constantize
  end

  def sort_direction
    :asc
  end
end
