module Validation
  module Rule
    # Boolean validation rule
    #
    # Valid is:
    # * a +String+: "true", "false", "t", "f", "yes", "no", "y", "n", "1", "0"
    # * a +Integer+: 1 or 0
    # * a +Boolean+: true or false
    class Boolean
      # The error key for this rule
      # @return [Symbol] error key
      def error_key
        :boolean
      end

      # Determines if value is a valid +boolean+
      def valid_value?(value)
        return false if value.nil?

        if value.is_a?(String)
          true if value =~ /\A(true|false|t|f|yes|no|y|n|1|0)\z/i
        elsif value.is_a?(Integer)
          true if value == 1 || value == 0
        elsif [true, false].include? value
          true
        else
          false
        end
      end

      # This rule has no params.
      # @return [Hash] params
      def params
        {}
      end
    end
  end
end
