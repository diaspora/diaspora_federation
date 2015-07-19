module Validation
  module Rule
    class NotNil
      attr_reader :params

      # no parameters
      def initialize
        @params = {}
      end

      def error_key
        :not_nil
      end

      def valid_value?(value)
        !value.nil?
      end
    end
  end
end
