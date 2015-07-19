module Validation
  module Rule
    class PublicKey
      attr_reader :params

      # no parameters
      def initialize
        @params = {}
      end

      def error_key
        :public_key
      end

      # allow both "PUBLIC KEY" and "RSA PUBLIC KEY"
      def valid_value?(value)
        (value.strip.start_with?("-----BEGIN PUBLIC KEY-----") &&
         value.strip.end_with?("-----END PUBLIC KEY-----")) ||
        (value.strip.start_with?("-----BEGIN RSA PUBLIC KEY-----") &&
          value.strip.end_with?("-----END RSA PUBLIC KEY-----"))
      end
    end
  end
end
