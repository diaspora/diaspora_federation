module Validation
  module Rule
    # URI validation rule

    # It allows +nil+, so maybe add an additional {Rule::NotNil} rule.
    class NilableURI < Validation::Rule::URI
      # The error key for this rule
      # @return [Symbol] error key
      def error_key
        :nilableURI
      end

      # Determines if value is a valid URI
      def valid_value?(uri_string)
        uri_string.nil? || super
      end
    end
  end
end
