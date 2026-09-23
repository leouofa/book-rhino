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

  def generate_scenes
    @component = Chapter.find(params[:id])
    @parent = @component.book
    
    if @component.scene_count.to_i > 0 && @component.content.present?
      WriteScenesJob.perform_later(@component.id)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to [@parent, @component], notice: 'Scene generation in progress...' }
      end
    else
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to [@parent, @component], alert: 'Chapter must be rendered and have a valid scene count.' }
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
    :outline
  end

  def component_params
    params.require(@computer_name.to_sym).permit(
      :outline, :scene_count
    )
  end
end
