class LocationsController < MetaController
  def component_name
    'Locations'
  end

  def component_class
    'Location'.constantize
  end

  def generate_prompt_job
    GenerateLocationPromptJob
  end

  def component_params
    params.require(@computer_name.to_sym).permit(
      :name,
      :region_id,
      :description,
      :lighting,
      :time,
      :noise_level,
      :comfort,
      :aesthetics,
      :accessibility,
      :personalization,
      character_ids: []
    )
  end
end
