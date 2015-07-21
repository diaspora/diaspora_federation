module Validation
  module Rule
    class NotNil
      def error_key
        :not_nil
      end

      def valid_value?(value)
        !value.nil?
      end

      # This rule has no params
      def params
        {}
      end
    end
  end
end
