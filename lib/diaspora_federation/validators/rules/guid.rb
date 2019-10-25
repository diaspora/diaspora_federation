# frozen_string_literal: true

module Validation
  module Rule
    # GUID validation rule
    #
    # Valid is a +String+ that is at least 16 and at most 255 chars long. It contains only:
    # * Letters: a-z
    # * Numbers: 0-9
    # * Special chars: '-', '_', '@', '.' and ':'
    # Special chars aren't allowed at the end.
    class Guid
      # Allowed chars to validate a GUID with a regex
      VALID_CHARS = "[0-9A-Za-z\\-_@.:]{15,254}[0-9A-Za-z]"

      # The error key for this rule
      # @return [Symbol] error key
      def error_key
        :guid
      end

      # Determines if value is a valid +GUID+
      def valid_value?(value)
        value.is_a?(String) && value =~ /\A#{VALID_CHARS}\z/
      end

      # This rule has no params.
      # @return [Hash] params
      def params
        {}
      end
    end
  end
end
