class CharactersController < MetaController
  def index
    scope = set_scope
    where = set_where
    @component_list = @component_klass.send('where', where).send(scope).order(created_at: :asc).page params[:page]
  end

  def edit_prompt
    set_component
  end

  def generate_prompt
    set_component
    GenerateCharacterPromptJob.perform_later(@component)

    respond_to do |format|
      format.turbo_stream { render :iterate }
    end
  end

  def iterate
    set_component
    message = params[:message]
    IterateOnCharacterPromptJob.perform_later(@component, message)

    respond_to do |format|
      format.turbo_stream
    end
  end

  def update
    if @component.update(component_params)
      if component_params[:prompt]
        redirect_to send(@component_detail_path, @component.id), notice: "#{@component_name} was successfully updated."
      else
        redirect_to send(@component_list_path), notice: "#{@component_name} was successfully updated."
      end
    else
      render component_params[:prompt] ? :edit_prompt : :edit
    end
  end

  private

  def component_name
    'Characters'
  end

  def component_class
    'Character'.constantize
  end

  def component_params
    params.require(@computer_name.to_sym).permit(:name, :gender, :age, :ethnicity, :nationality, :appearance, :health,
                                                 :fears, :desires, :backstory, :skills, :values, :prompt,
                                                 character_type_ids: [], moral_alignment_ids: [],
                                                 personality_trait_ids: [], archetype_ids: [])
  end
end
