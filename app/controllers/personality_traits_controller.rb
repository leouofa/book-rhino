class PersonalityTraitsController < MetaController
  def component_name
    'Personality Traits'
  end

  def component_class
    'PersonalityTrait'.constantize
  end

  def sort_direction
    :asc
  end
end
