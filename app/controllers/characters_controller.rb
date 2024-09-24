class CharactersController < MetaController
  def index
    scope = set_scope
    where = set_where
    @component_list = @component_klass.send('where', where).send(scope).order(created_at: :asc).page params[:page]
  end

  def component_name
    'Characters'
  end

  def component_class
    'Character'.constantize
  end
end
