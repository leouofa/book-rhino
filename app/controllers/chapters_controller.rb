class ChaptersController < MetaController
  def render_chapter
    @component = Chapter.find(params[:id])
    @parent = @component.book

    if @component.can_render?
      @component.update(rendering: true)
      RenderChapterJob.perform_later(@component)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to [@parent, @component], notice: 'Rendering chapter in progress...' }
      end
    else
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to [@parent, @component], alert: 'Previous chapter must be rendered first.' }
      end
    end
  end

  private

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

  def prompt_attribute_name
    :plot_summary
  end

  def component_params
    params.require(@computer_name.to_sym).permit(
      :plot_summary
    )
  end
end
