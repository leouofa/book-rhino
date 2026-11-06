# frozen_string_literal: true

module Api
  module V1
    class TextSerializer < BaseSerializer
      def as_json
        {
          id: record.id,
          writing_style_id: record.writing_style_id,
          name: record.name,
          corpus: record.corpus,
          created_at: format_time(record.created_at),
          updated_at: format_time(record.updated_at)
        }
      end
    end
  end
end
