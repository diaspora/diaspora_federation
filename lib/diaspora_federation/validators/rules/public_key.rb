module Validation
  module Rule
    # Public key validation rule
    #
    # A valid key must:
    # * start with "-----BEGIN PUBLIC KEY-----" and end with "-----END PUBLIC KEY-----"
    # or
    # * start with "-----BEGIN RSA PUBLIC KEY-----" and end with "-----END RSA PUBLIC KEY-----"
    class PublicKey
      # The error key for this rule
      # @return [Symbol] error key
      def error_key
        :public_key
      end

      # Determines if value is a valid public key
      def valid_value?(value)
        !value.nil? && (
          (value.strip.start_with?("-----BEGIN PUBLIC KEY-----") &&
           value.strip.end_with?("-----END PUBLIC KEY-----")) ||
          (value.strip.start_with?("-----BEGIN RSA PUBLIC KEY-----") &&
            value.strip.end_with?("-----END RSA PUBLIC KEY-----"))
        )
      end

      # This rule has no params.
      # @return [Hash] params
      def params
        {}
      end
    end
  end
end
