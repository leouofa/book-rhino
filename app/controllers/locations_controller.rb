class LocationsController < MetaController
  def component_name
    'Locations'
  end

  def component_class
    'Location'.constantize
  end

  def component_params
    params.require(@computer_name.to_sym).permit(
      :name,
      :lighting,
      :time,
      :noise_level,
      :comfort,
      :aesthetics,
      :accessibility,
      :personalization
    )
  end
end
