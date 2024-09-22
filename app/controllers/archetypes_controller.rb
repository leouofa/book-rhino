class ArchetypesController < MetaController
  def index
    scope = set_scope
    where = set_where
    @component_list = @component_klass.send('where', where).send(scope).order(created_at: :asc).page params[:page]
  end

  def component_name
    'Archetypes'
  end

  def component_class
    'Archetype'.constantize
  end
end
