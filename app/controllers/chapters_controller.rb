class ChaptersController < MetaController
  def component_name
    'Chapters'
  end

  def component_class
    'Chapter'.constantize
  end

  def prefix
    'book_'
  end

  def parent_class
    Book
  end

  def iterate_job
    # Placeholder to satisfy MetaController
  end

  def generate_prompt_job
    # Placeholder to satisfy MetaController
  end

  def update
    if @component.update(component_params)
      path = parent_class ? send(@component_detail_path, @parent, @component) : send(@component_detail_path, @component.id)
      redirect_to path, notice: "#{@component_name} was successfully updated."
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
