module Validation
  module Rule
    # URI validation rule
    #
    # This rule is based on https://github.com/zombor/Validator/blob/master/lib/validation/rule/uri.rb
    #
    # It allows +nil+, so maybe add an additional {Rule::NotNil} rule.
    class URI
      # @param [Array<Symbol>] parts the parts that are required
      def initialize(parts=%i(scheme host))
        @required_parts = parts
      end

      # The error key for this rule
      # @return [Symbol] error key
      def error_key
        :URI
      end

      # This rule has a +required_elements+ param
      # @return [Hash] params
      def params
        {required_elements: @required_parts}
      end

      # Determines if value is a valid URI
      def valid_value?(uri_string)
        return true if uri_string.nil?

        uri = URI(uri_string)
        @required_parts.each do |part|
          return false if uri.public_send(part).nil? || uri.public_send(part).empty?
        end

        true
      rescue ::URI::InvalidURIError
        false
      end
    end
  end
end
