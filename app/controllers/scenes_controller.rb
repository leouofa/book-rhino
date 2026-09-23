class ScenesController < MetaController
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
