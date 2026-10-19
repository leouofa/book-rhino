class CinematicStylesController < MetaController
  def component_name
    'Cinematic Styles'
  end

  def component_class
    'CinematicStyle'.constantize
  end

  def sort_direction
    :asc
  end
end
