class CrudComponentGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)
  argument :attributes, type: :array, default: [], banner: "field:type field:type"

  def create_model
    generate :model, "#{file_name} #{attributes.join(' ')}"
  end

  def create_controller
    template "controller.rb", "app/controllers/#{plural_file_name}_controller.rb"
  end

  def create_views
    template "_form.html.slim", "app/views/#{plural_file_name}/_form.html.slim"
    template "edit.html.slim", "app/views/#{plural_file_name}/edit.html.slim"
    template "index.html.slim", "app/views/#{plural_file_name}/index.html.slim"
    template "new.html.slim", "app/views/#{plural_file_name}/new.html.slim"
    template "show.html.slim", "app/views/#{plural_file_name}/show.html.slim"
  end

  def add_routes
    route "resources :#{plural_file_name}"
  end

  private

  def attribute_names
    attributes.map { |attr| attr.name }
  end
end
