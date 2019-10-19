# frozen_string_literal: true

module Validation
  module Rule
    # Validates that a property is not +nil+
    class NotNil
      # The error key for this rule
      # @return [Symbol] error key
      def error_key
        :not_nil
      end

      # Determines if value is not nil
      def valid_value?(value)
        !value.nil?
      end

      # This rule has no params.
      # @return [Hash] params
      def params
        {}
      end
    end
  end
end
