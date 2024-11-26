class <%= class_name.pluralize %>Controller < MetaController
  def component_name
    '<%= class_name.pluralize %>'
  end

  def component_class
    '<%= class_name %>'.constantize
  end

  def component_params
    params.require(@computer_name.to_sym).permit(
      <%= attribute_names.map { |name| ":#{name}" }.join(",\n      ") %>
    )
  end
end
