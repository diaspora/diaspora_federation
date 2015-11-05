module Validation
  module Rule
    # Rule for validating the number of Diaspora* ids in a string.
    # The evaluated string is split at ";" and the result will be counted.
    class DiasporaIdCount
      attr_reader :params

      # @param [Hash] params
      # @option params [Fixnum] :maximum maximum allowed id count
      def initialize(params)
        unless params.include?(:maximum) && params[:maximum].is_a?(Fixnum)
          raise "A number has to be specified for :maximum"
        end

        @params = params
      end

      def error_key
        :diaspora_id_count
      end

      def valid_value?(value)
        ids = value.split(";")
        return false unless ids.count <= params[:maximum]
        ids.each do |id|
          return false unless DiasporaId.new.valid_value?(id)
        end
        true
      end
    end
  end
end
