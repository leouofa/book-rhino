module MetaHelper
  def parent_reference(form, parent)
    form.hidden_field("#{parent.class.name.underscore}_id", value: parent.id)
  end
end
