class WritingStyleTextsController < MetaController

  private

  def component_name
    'Writing Style Texts'
  end

  def component_class
    'WritingStyleText'.constantize
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



  # def set_component
  #   @component_klass = 'WritingStyleText'.constantize
  #   @component_name = 'Writing Style Text'
  #   @component_list_path = 'writing_styles_path'
  #   @component_path = 'writing_style_path'
  #   @component_new_path = 'new_writing_style_path'
  # end

  # def component_params
  #   params.require(:writing_style).permit(:name)
  # end
  #
  # def set_scope
  #   'all'
  # end
end
