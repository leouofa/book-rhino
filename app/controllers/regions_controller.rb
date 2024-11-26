class RegionsController < MetaController
  def component_name
    'Regions'
  end

  def component_class
    'Region'.constantize
  end

  def component_params
    params.require(@computer_name.to_sym).permit(
      :name,
      :city,
      :country,
      :description
    )
  end
end
