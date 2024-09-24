namespace :import do
  desc "Import perspectives from a YAML file"
  task perspectives: :environment do
    yaml_file = Rails.root.join("blueprints/perspectives.yml")
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

  desc "Import archetypes from YAML file"
  task archetypes: :environment do
    file_path = Rails.root.join("blueprints/archetypes.yml")

    if File.exist?(file_path)
      archetypes_data = YAML.load_file(file_path)['archetypes']

      archetypes_data.each do |archetype_data|
        archetype = Archetype.find_or_initialize_by(name: archetype_data['name'])
        archetype.traits = archetype_data['traits']
        archetype.examples = archetype_data['examples']

        if archetype.save
          puts "Successfully imported: #{archetype.name}"
        else
          puts "Failed to import: #{archetype.name}"
          puts archetype.errors.full_messages
        end
      end

      puts "Archetypes import completed."
    else
      puts "File not found: #{file_path}"
    end
  end

  desc "Import personality traits from a YAML file"
  task personality_traits: :environment do
    yaml_file = Rails.root.join("blueprints/personality_traits.yml")
    personality_traits = YAML.load_file(yaml_file)['personality_traits']

    personality_traits.each do |trait_data|
      trait = PersonalityTrait.find_or_initialize_by(name: trait_data['name'])
      trait.description = trait_data['description']

      if trait.save
        puts "Successfully imported: #{trait.name}"
      else
        puts "Failed to import: #{trait.name}"
        puts trait.errors.full_messages
      end
    end
  end

  desc "Import moral alignments from a YAML file"
  task moral_alignments: :environment do
    yaml_file = Rails.root.join("blueprints/moral_alignments.yml")
    alignments = YAML.load_file(yaml_file)['moral_alignments']

    alignments.each do |alignment_data|
      alignment = MoralAlignment.find_or_initialize_by(name: alignment_data['name'])
      alignment.description = alignment_data['description']
      alignment.examples = alignment_data['examples']

      if alignment.save
        puts "Successfully imported: #{alignment.name}"
      else
        puts "Failed to import: #{alignment.name}"
        puts alignment.errors.full_messages
      end
    end
  end
end
