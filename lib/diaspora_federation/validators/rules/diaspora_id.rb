module Validation
  module Rule
    # Diaspora ID validation rule
    #
    # A simple rule to validate the base structure of diaspora IDs.
    class DiasporaId
      # The Regex for a valid diaspora ID
      DIASPORA_ID = begin
        letter         = "a-zA-Z"
        digit          = "0-9"
        hexadecimal    = "[a-fA-F#{digit}]"
        username       = "[#{letter}#{digit}\\-\\_\\.]+"
        hostname_part  = "[#{letter}#{digit}\\-]"
        hostname       = "#{hostname_part}+([.]#{hostname_part}*)*"
        ipv4           = "(?:[#{digit}]{1,3}\\.){3}[#{digit}]{1,3}"
        ipv6           = "\\[(?:#{hexadecimal}{0,4}:){0,7}#{hexadecimal}{1,4}\\]"
        ip_addr        = "(?:#{ipv4}|#{ipv6})"
        domain         = "(?:#{hostname}|#{ip_addr})"
        port           = "(:[#{digit}]+)?"
        addr_spec      = "(#{username}\\@#{domain}#{port})?"

        /\A#{addr_spec}\z/u
      end

      # The error key for this rule
      # @return [Symbol] error key
      def error_key
        :diaspora_id
      end

      # Determines if value is a valid diaspora ID
      def valid_value?(value)
        value.nil? || !DIASPORA_ID.match(value).nil?
      end

      # This rule has no params
      # @return [Hash] params
      def params
        {}
      end
    end
  end
end
