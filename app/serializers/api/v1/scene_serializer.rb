# frozen_string_literal: true

module Api
  module V1
    class SceneSerializer < BaseSerializer
      def as_json
        {
          id: record.id,
          chapter_id: record.chapter_id,
          number: record.number,
          outline: record.outline,
          content: record.content,
          summary: record.summary,
          rendering: record.rendering?,
          can_render: record.can_render?,
          created_at: format_time(record.created_at),
          updated_at: format_time(record.updated_at)
        }
      end
    end
  end
end
