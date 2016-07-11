module Validation
  module Rule
    # Rule for validating the number of diaspora* IDs in a string.
    # The evaluated string is split at ";" and the result will be counted.
    class DiasporaIdCount
      # This rule must have a +maximum+ param.
      # @return [Hash] params
      attr_reader :params

      # Creates a new rule for a maximum diaspora* ID count validation
      # @param [Hash] params
      # @option params [Fixnum] :maximum maximum allowed id count
      def initialize(params)
        unless params.include?(:maximum) && params[:maximum].is_a?(Fixnum)
          raise ArgumentError, "A number has to be specified for :maximum"
        end

        @params = params
      end

      # The error key for this rule
      # @return [Symbol] error key
      def error_key
        :diaspora_id_count
      end

      def valid_value?(value)
        ids = value.split(";")
        return false unless ids.count <= params[:maximum]
        ids.each do |id|
          return false if DiasporaId::DIASPORA_ID.match(id).nil?
        end
        true
      end
    end
  end
end
