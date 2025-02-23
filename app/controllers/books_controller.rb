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

  def read
    @component = Book.find(params[:id])
  end

  def render_book
    @component = Book.find(params[:id])
    @component.update(pending: true)
    RenderBookJob.perform_now(@component)

    respond_to do |format|
      format.turbo_stream { render :iterate }
      format.html { redirect_to @component, notice: 'Rendering book...' }
    end
  end

  def extract_chapters
    @component = Book.find(params[:id])
    @component.update(pending: true)
    ExtractChaptersJob.perform_later(@component)

    respond_to do |format|
      format.turbo_stream { render :iterate }
      format.html { redirect_to @component, notice: 'Extracting chapters...' }
    end
  end

  def write_chapters
    @component = Book.find(params[:id])
    @component.update(pending: true)
    WriteChaptersJob.perform_later(@component)

    respond_to do |format|
      format.turbo_stream { render :iterate }
      format.html { redirect_to @component, notice: 'Writing chapters...' }
    end
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
      :chapter_count,
      :pages,
      :protagonist_id,
      antagonist_ids: [],
      character_ids: []
    )
  end
end
