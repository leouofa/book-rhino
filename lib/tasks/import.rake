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

  desc "Import narrative structures from a YAML file"
  task narrative_structures: :environment do
    yaml_file = Rails.root.join("blueprints/narrative_structures.yml")
    structures = YAML.load_file(yaml_file)['narrative_structures']

    structures.each do |structure_data|
      narrative_structure = NarrativeStructure.find_or_initialize_by(name: structure_data['name'])
      narrative_structure.description = structure_data['description']
      narrative_structure.parts = structure_data['parts']

      if narrative_structure.save
        puts "Successfully imported: #{narrative_structure.name}"
      else
        puts "Failed to import: #{narrative_structure.name}"
        puts narrative_structure.errors.full_messages
      end
    end
  end

  desc "Import character types from a YAML file"
  task character_types: :environment do
    yaml_file = Rails.root.join("blueprints/character_types.yml")
    character_types = YAML.load_file(yaml_file)['characters']

    character_types.each do |character_data|
      character_type = CharacterType.find_or_initialize_by(name: character_data['type'])
      character_type.definition = character_data['definition']
      character_type.purpose = character_data['purpose']
      character_type.example = character_data['example']

      if character_type.save
        puts "Successfully imported: #{character_type.name}"
      else
        puts "Failed to import: #{character_type.name}"
        puts character_type.errors.full_messages
      end
    end
  end

  desc "Import locations from a YAML file"
  task locations: :environment do
    yaml_file = Rails.root.join("blueprints/locations.yml")
    locations = YAML.load_file(yaml_file)['locations']

    locations.each do |location_data|
      location = Location.find_or_initialize_by(name: location_data['name'])
      location.description = location_data['description']
      location.examples = location_data['examples']

      if location.save
        puts "Successfully imported: #{location.name}"
      else
        puts "Failed to import: #{location.name}"
        puts location.errors.full_messages
      end
    end
  end
end
