# frozen_string_literal: true

module Api
  module V1
    class WritingStyleSerializer < BaseSerializer
      def as_json
        parsed_prompt = parse_prompt(record.prompt)
        data = {
          id: record.id,
          name: record.name,
          prompt: parsed_prompt,
          pending: record.pending?,
          created_at: format_time(record.created_at),
          updated_at: format_time(record.updated_at)
        }

        if options[:include_texts]
          data[:texts] = TextSerializer.render(record.texts.order(:created_at))
        else
          data[:texts_count] = record.texts.size
        end

        data
      end

      private

      def parse_prompt(raw)
        return nil if raw.blank?
        return raw if raw.is_a?(Hash) || raw.is_a?(Array)

        JSON.parse(raw)
      rescue JSON::ParserError
        raw
      end
    end
  end
end
