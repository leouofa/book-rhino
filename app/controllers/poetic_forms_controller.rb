class PoeticFormsController < MetaController
  def component_name
    'Poetic Forms'
  end

  def component_class
    'PoeticForm'.constantize
  end

  def sort_direction
    :asc
  end
end
