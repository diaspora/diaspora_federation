require "date"

module Validation
  module Rule
    class Birthday
      def error_key
        :birthday
      end

      def valid_value?(value)
        return true if value.nil? || (value.is_a?(String) && value.empty?)
        return true if value.is_a? Date

        if value =~ /[0-9]{4}\-[0-9]{2}\-[0-9]{2}/
          date_field = value.split("-").map(&:to_i)
          return Date.valid_civil?(date_field[0], date_field[1], date_field[2])
        end

        false
      end

      # This rule has no params
      def params
        {}
      end
    end
  end
end
