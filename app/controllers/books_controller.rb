class BooksController < MetaController
  def component_name
    'Books'
  end

  def component_class
    'Book'.constantize
  end

  def iterate_job
    IterateOnBookPlotJob
  end

  def generate_prompt_job
    GenerateBookPlotJob
  end

  def component_params
    params.require(@computer_name.to_sym).permit(
      :title,
      :writing_style_id,
      :perspective_id,
      :narrative_structure_id,
      :moral,
      :plot,
      :chapters,
      :pages,
      :protagonist_id,
      antagonist_ids: [],
      character_ids: []
    )
  end
end
