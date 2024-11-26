class TextsController < MetaController
  private

  def component_name
    'Texts'
  end

  def component_class
    'Text'.constantize
  end

  def prefix
    'writing_style_'
  end

  def parent_class
    WritingStyle
  end

  def component_params
    params.require(@computer_name.to_sym).permit(:name, :corpus, :writing_style_id)
  end
end
