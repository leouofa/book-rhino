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
    @parent_name = 'Writing Styles'
    @parent_computer_name = 'writing_style'
    @parent_path = 'writing_styles_path'
    @parent_edit_prompt_path = 'edit_prompt_writing_style_path'
    @parent_generate_prompt_path = 'generate_prompt_writing_style_path'
  end

  def component_params
    params.require(@computer_name.to_sym).permit(:name, :corpus, :writing_style_id)
  end
end
