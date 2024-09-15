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

  def set_where
    { writing_style_id: params[:writing_style_id] }
  end

  def set_parent
    @parent = WritingStyle.find(params[:writing_style_id])
  end

  def component_params
    params.require(@computer_name.to_sym).permit(:corpus)
  end
end
