class WritingStylesController < MetaController
  private

  def component_name
    'Writing Styles'
  end

  def component_class
    'WritingStyle'.constantize
  end

  def component_params
    params.require(@computer_name.to_sym).permit(:name)
  end
end
