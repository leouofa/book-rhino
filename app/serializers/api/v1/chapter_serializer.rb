# frozen_string_literal: true

module Api
  module V1
    class ChapterSerializer < BaseSerializer
      def as_json
        data = {
          id: record.id,
          book_id: record.book_id,
          number: record.number,
          name: record.name,
          outline: record.outline,
          content: record.content,
          summary: record.summary,
          scene_count: record.scene_count,
          rendering: record.rendering?,
          can_render: record.can_render?,
          word_count: record.content.present? ? record.content.split(/\s+/).size : 0,
          created_at: format_time(record.created_at),
          updated_at: format_time(record.updated_at)
        }

        if options[:include_scenes]
          data[:scenes] = SceneSerializer.render(record.scenes.order(:number))
        else
          data[:scenes_count] = record.scenes.size
        end

        data
      end
    end
  end
end
