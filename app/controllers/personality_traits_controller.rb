class PersonalityTraitsController < MetaController
  def index
    scope = set_scope
    where = set_where
    @component_list = @component_klass.send('where', where).send(scope).order(created_at: :asc).page params[:page]
  end

  def component_name
    'Personality Traits'
  end

  def component_class
    'PersonalityTrait'.constantize
  end
end
