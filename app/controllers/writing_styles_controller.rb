class WritingStylesController < MetaController
  def show
    redirect_to writing_style_texts_path(writing_style_id: @component.id)
  end

  private

  def component_name
    'Writing Styles'
  end

  def component_class
    'WritingStyle'.constantize
  end

  def iterate_job
    IterateOnWritingStyleJob
  end

  def generate_prompt_job
    GenerateWritingStyleJob
  end

  def component_params
    params.require(@computer_name.to_sym).permit(:name, :prompt)
  end
end
