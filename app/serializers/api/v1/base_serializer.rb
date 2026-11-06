# frozen_string_literal: true

module Api
  module V1
    class BaseSerializer
      def self.render(resource, **options)
        return nil if resource.nil?

        if resource.respond_to?(:to_ary)
          resource.map { |item| new(item, **options).as_json }
        else
          new(resource, **options).as_json
        end
      end

      attr_reader :record, :options

      def initialize(record, **options)
        @record = record
        @options = options
      end

      def as_json
        raise NotImplementedError, "#{self.class.name} must implement #as_json"
      end

      private

      def format_time(time)
        time&.iso8601
      end
    end
  end
end
