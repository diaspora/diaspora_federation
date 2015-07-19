module Validation
  module Rule
    class Boolean
      attr_reader :params

      # no parameters
      def initialize
        @params = {}
      end

      def error_key
        :numeric
      end

      def valid_value?(value)
        return false if value.nil?

        if value.is_a?(String)
          true if value =~ /\A(true|false|t|f|yes|no|y|n|1|0)\z/i
        elsif value.is_a?(Fixnum)
          true if value == 1 || value == 0
        elsif value.is_a?(TrueClass) || value.is_a?(FalseClass)
          true
        else
          false
        end
      end
    end
  end
end
