# frozen_string_literal: true

module Api
  module V1
    class CharacterSerializer < BaseSerializer
      def as_json
        data = {
          id: record.id,
          name: record.name,
          gender: record.gender,
          age: record.age,
          ethnicity: record.ethnicity,
          nationality: record.nationality,
          appearance: record.appearance,
          health: record.health,
          fears: record.fears,
          desires: record.desires,
          backstory: record.backstory,
          skills: record.skills,
          values: record.values,
          prompt: record.prompt,
          pending: record.pending?,
          created_at: format_time(record.created_at),
          updated_at: format_time(record.updated_at)
        }

        if options[:detailed]
          data[:character_types] = record.character_types.map { |t| { id: t.id, name: t.name } }
          data[:moral_alignments] = record.moral_alignments.map { |m| { id: m.id, name: m.name } }
          data[:personality_traits] = record.personality_traits.map { |p| { id: p.id, name: p.name } }
          data[:archetypes] = record.archetypes.map { |a| { id: a.id, name: a.name } }
          data[:locations] = record.locations.map { |l| { id: l.id, name: l.name } }
          data[:images] = ImageSerializer.render(record.character_images)
          data[:book_ids] = record.book_ids
        else
          data[:character_type_ids] = record.character_type_ids
          data[:moral_alignment_ids] = record.moral_alignment_ids
          data[:personality_trait_ids] = record.personality_trait_ids
          data[:archetype_ids] = record.archetype_ids
          data[:images_count] = record.character_images.size
        end

        data
      end
    end
  end
end
