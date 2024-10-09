class NarrativeStructuresController < MetaController
  def index
    scope = set_scope
    where = set_where
    @component_list = @component_klass.send('where', where).send(scope).order(created_at: :asc).page params[:page]
  end

  def component_name
    'Narrative Structures'
  end

  def component_class
    'NarrativeStructure'.constantize
  end
end
