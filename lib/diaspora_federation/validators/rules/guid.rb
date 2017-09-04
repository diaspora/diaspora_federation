module Validation
  module Rule
    # GUID validation rule
    #
    # Valid is a +String+ that is at least 16 and at most 255 chars long. It contains only:
    # * Letters: a-z
    # * Numbers: 0-9
    # * Special chars: '-', '_', '@', '.' and ':'
    class Guid
      # The error key for this rule
      # @return [Symbol] error key
      def error_key
        :guid
      end

      # Determines if value is a valid +GUID+
      def valid_value?(value)
        value.is_a?(String) && value.downcase =~ /\A[0-9a-z\-_@.:]{16,255}\z/
      end

      # This rule has no params.
      # @return [Hash] params
      def params
        {}
      end
    end
  end
end
