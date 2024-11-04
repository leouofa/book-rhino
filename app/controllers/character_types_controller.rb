class CharacterTypesController < MetaController
  def component_name
    'Character Types'
  end

  def component_class
    'CharacterType'.constantize
  end

  def sort_direction
    :asc
  end

  def component_params
    params.require(@computer_name.to_sym).permit(:name, :gender, :age, :ethnicity, :nationality, :appearance,
                                                 :health, :fears, :desires, :backstory, :skills, :values)
  end
end
