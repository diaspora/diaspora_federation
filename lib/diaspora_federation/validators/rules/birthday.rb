# frozen_string_literal: true

require "date"

module Validation
  module Rule
    # Birthday validation rule
    #
    # Valid is:
    # * nil or an empty +String+
    # * a +Date+ object
    # * a +String+ with the format "yyyy-mm-dd" and is a valid +Date+, example: 2015-07-25
    class Birthday
      # The error key for this rule
      # @return [Symbol] error key
      def error_key
        :birthday
      end

      # Determines if value is a valid birthday date.
      def valid_value?(value)
        return true if value.nil? || (value.is_a?(String) && value.empty?)
        return true if value.is_a? Date

        if value.is_a?(String) && value.match?(/[0-9]{4}-[0-9]{2}-[0-9]{2}/)
          date_field = value.split("-").map(&:to_i)
          return Date.valid_civil?(date_field[0], date_field[1], date_field[2])
        end

        false
      end

      # This rule has no params.
      # @return [Hash] params
      def params
        {}
      end
    end
  end
end
