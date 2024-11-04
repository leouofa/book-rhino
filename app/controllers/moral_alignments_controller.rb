class MoralAlignmentsController < MetaController
  def component_name
    'Moral Alignments'
  end

  def component_class
    'MoralAlignment'.constantize
  end

  def sort_direction
    :asc
  end
end
