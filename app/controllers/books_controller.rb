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

  def update
    if @component.update(component_params)
      if component_params[:plot]
        redirect_to send(@component_detail_path, @component.id), notice: "#{@component_name} was successfully updated."
      else
        redirect_to send(@component_list_path), notice: "#{@component_name} was successfully updated."
      end
    else
      render component_params[:plot] ? :edit_prompt : :edit
    end
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
