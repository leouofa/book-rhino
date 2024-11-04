class WritingStylesController < MetaController
  def iterate
    set_component
    message = params[:message]
    IterateOnWritingStyleJob.perform_later(@component, message)

    @parent = @component
    respond_to do |format|
      format.turbo_stream
    end
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

  def component_params
    params.require(@computer_name.to_sym).permit(:name)
  end
end
