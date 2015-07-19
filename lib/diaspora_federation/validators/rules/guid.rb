module Validation
  module Rule
    class Guid
      attr_reader :params

      # no parameters
      def initialize
        @params = {}
      end

      def error_key
        :guid
      end

      def valid_value?(value)
        value.is_a?(String) && value.downcase =~ /\A[0-9a-z\-_@.:]{16,}\z/
      end
    end
  end
end
