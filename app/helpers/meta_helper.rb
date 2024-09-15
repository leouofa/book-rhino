module MetaHelper
  def parent_reference(form, parent)
    form.hidden_field("#{parent.class.name.underscore}_id", value: parent.id)
  end

  def breadcrumb_parent(name, path)
    link_to(name, path, class: 'text-blue-700 hover:text-blue-700') + '&nbsp;/&nbsp;'.html_safe
  end
end
