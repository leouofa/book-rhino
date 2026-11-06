# frozen_string_literal: true

module Api
  module V1
    class BookSerializer < BaseSerializer
      def as_json
        if options[:manuscript]
          render_manuscript
        else
          render_standard
        end
      end

      private

      def render_standard
        data = {
          id: record.id,
          title: record.title,
          moral: record.moral,
          plot: record.plot,
          chapter_count: record.chapter_count,
          pages: record.pages,
          pending: record.pending?,
          rendering: record.rendering?,
          writing_style_id: record.writing_style_id,
          perspective_id: record.perspective_id,
          narrative_structure_id: record.narrative_structure_id,
          poetic_form_id: record.poetic_form_id,
          cinematic_style_id: record.cinematic_style_id,
          protagonist_id: record.protagonist_id,
          created_at: format_time(record.created_at),
          updated_at: format_time(record.updated_at)
        }

        if options[:detailed]
          data[:writing_style] = record.writing_style ? { id: record.writing_style.id, name: record.writing_style.name } : nil
          data[:perspective] = record.perspective ? { id: record.perspective.id, name: record.perspective.name } : nil
          data[:narrative_structure] = record.narrative_structure ? { id: record.narrative_structure.id, name: record.narrative_structure.name } : nil
          data[:poetic_form] = record.poetic_form ? { id: record.poetic_form.id, name: record.poetic_form.name } : nil
          data[:cinematic_style] = record.cinematic_style ? { id: record.cinematic_style.id, name: record.cinematic_style.name } : nil
          data[:protagonist] = record.protagonist ? { id: record.protagonist.id, name: record.protagonist.name } : nil
          data[:antagonists] = record.antagonists.map { |a| { id: a.id, name: a.name } }
          data[:characters] = record.characters.map { |c| { id: c.id, name: c.name } }
          data[:locations] = record.locations.map { |l| { id: l.id, name: l.name } }
          data[:chapters] = ChapterSerializer.render(record.chapters.order(:number), include_scenes: true)
        else
          data[:antagonist_ids] = record.antagonist_ids
          data[:character_ids] = record.character_ids
          data[:location_ids] = record.location_ids
          data[:actual_chapters_count] = record.chapters.size
        end

        data
      end

      def render_manuscript
        chapters_data = record.chapters.order(:number).map do |chap|
          ChapterSerializer.render(chap, include_scenes: true)
        end

        total_words = chapters_data.sum { |c| c[:word_count] || 0 }

        # Build compiled Markdown
        markdown_lines = ["# #{record.title}\n"]
        chapters_data.each do |c|
          markdown_lines << "## Chapter #{c[:number]}: #{c[:name]}\n"
          markdown_lines << "#{c[:content]}\n" if c[:content].present?
        end

        {
          id: record.id,
          title: record.title,
          total_chapters: chapters_data.size,
          total_word_count: total_words,
          markdown: markdown_lines.join("\n"),
          chapters: chapters_data
        }
      end
    end
  end
end
