namespace :import do
  desc "Import perspectives from a YAML file"
  task perspectives: :environment do
    yaml_file = Rails.root.join('blueprints', 'perspectives.yml')
    perspectives = YAML.load_file(yaml_file)['perspectives']

    perspectives.each do |perspective_data|
      perspective = Perspective.find_or_initialize_by(name: perspective_data['name'])
      perspective.narrator = perspective_data['narrator']
      perspective.pronouns = perspective_data['pronouns']
      perspective.effect = perspective_data['effect']
      perspective.example = perspective_data['example']

      if perspective.save
        puts "Successfully imported: #{perspective.name}"
      else
        puts "Failed to import: #{perspective.name}"
        puts perspective.errors.full_messages
      end
    end
  end
end
