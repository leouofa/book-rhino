class CharactersController < MetaController
  def index
    scope = set_scope
    where = set_where
    @component_list = @component_klass.send('where', where).send(scope).order(created_at: :asc).page params[:page]
  end

  private

  def component_name
    'Characters'
  end

  def component_class
    'Character'.constantize
  end

  def iterate_job
    IterateOnCharacterPromptJob
  end

  def generate_prompt_job
    GenerateCharacterPromptJob
  end

  def component_params
    params.require(@computer_name.to_sym).permit(:name, :gender, :age, :ethnicity, :nationality, :appearance, :health,
                                                 :fears, :desires, :backstory, :skills, :values, :prompt,
                                                 character_type_ids: [], moral_alignment_ids: [],
                                                 personality_trait_ids: [], archetype_ids: [])
  end
end
