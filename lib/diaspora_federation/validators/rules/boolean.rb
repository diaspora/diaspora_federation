module Validation
  module Rule
    class Boolean
      def error_key
        :numeric
      end

      def valid_value?(value)
        return false if value.nil?

        if value.is_a?(String)
          true if value =~ /\A(true|false|t|f|yes|no|y|n|1|0)\z/i
        elsif value.is_a?(Fixnum)
          true if value == 1 || value == 0
        elsif [true, false].include? value
          true
        else
          false
        end
      end

      # This rule has no params
      def params
        {}
      end
    end
  end
end
