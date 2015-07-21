module Validation
  module Rule
    class Guid
      def error_key
        :guid
      end

      def valid_value?(value)
        value.is_a?(String) && value.downcase =~ /\A[0-9a-z\-_@.:]{16,}\z/
      end

      # This rule has no params
      def params
        {}
      end
    end
  end
end
