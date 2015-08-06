module Validation
  module Rule
    # Diaspora ID validation rule
    #
    # This rule is based on https://github.com/zombor/Validator/blob/master/lib/validation/rule/email.rb
    # which was adapted from https://github.com/emmanuel/aequitas/blob/master/lib/aequitas/rule/format/email_address.rb
    class DiasporaId
      # The Regex for a valid diaspora ID
      DIASPORA_ID = begin
        letter         = "a-zA-Z"
        digit          = "0-9"
        username       = "[#{letter}#{digit}\\-\\_\\.]+"
        atext          = "[#{letter}#{digit}+\\=\\-\\_]"
        dot_atom       = "#{atext}+([.]#{atext}*)*"
        no_ws_ctl      = '\x01-\x08\x11\x12\x14-\x1f\x7f'
        text           = '[\x01-\x09\x11\x12\x14-\x7f]'
        quoted_pair    = "(\\x5c#{text})"
        dtext          = "[#{no_ws_ctl}\\x21-\\x5a\\x5e-\\x7e]"
        dcontent       = "(?:#{dtext}|#{quoted_pair})"
        domain_literal = "\\[#{dcontent}+\\]"
        domain         = "(?:#{dot_atom}|#{domain_literal})"
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
