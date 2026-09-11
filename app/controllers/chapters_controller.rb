class ChaptersController < MetaController
  def component_name
    'Chapters'
  end

  def component_class
    'Chapter'.constantize
  end

  def iterate_job
    # Placeholder to satisfy MetaController
  end

  def generate_prompt_job
    # Placeholder to satisfy MetaController
  end

  def update
    if @component.update(component_params)
      redirect_to send(@component_detail_path, @component.id), notice: "#{@component_name} was successfully updated."
    else
      render component_params[:plot_summary] ? :edit_prompt : :edit
    end
  end

  def component_params
    params.require(@computer_name.to_sym).permit(
      :plot_summary
    )
  end
end
