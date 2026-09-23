class ScenesController < MetaController
  def render_scene
    @component = Scene.find(params[:id])
    @parent = @component.chapter

    if @component.can_render?
      @component.update(rendering: true)
      RenderSceneJob.perform_later(@component)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to [@parent.book, @parent, @component], notice: 'Rendering scene in progress...' }
      end
    else
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to [@parent.book, @parent, @component], alert: 'Scene cannot be rendered.' }
      end
    end
  end
  private

  def component_name
    'Scene'
  end

  def component_class
    Scene
  end

  def prefix
    'chapter_'
  end

  def parent_class
    Chapter
  end

  def iterate_job
  end

  def generate_prompt_job
  end

  def component_params
    params.require(:scene).permit(
      :outline, :content, :summary
    )
  end
end
