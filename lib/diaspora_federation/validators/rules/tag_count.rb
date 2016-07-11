module Validation
  module Rule
    # Rule for validating the number of tags in a string.
    # Only the "#" characters will be counted.
    # The string can be nil.
    class TagCount
      # This rule must have a +maximum+ param.
      # @return [Hash] params
      attr_reader :params

      # Creates a new rule for a maximum tag count validation
      # @param [Hash] params
      # @option params [Fixnum] :maximum maximum allowed tag count
      def initialize(params)
        unless params.include?(:maximum) && params[:maximum].is_a?(Fixnum)
          raise ArgumentError, "A number has to be specified for :maximum"
        end

        @params = params
      end

      # The error key for this rule
      # @return [Symbol] error key
      def error_key
        :tag_count
      end

      # Determines if value doesn't have more than +maximum+ tags
      def valid_value?(value)
        value.nil? || value.count("#") <= params[:maximum]
      end
    end
  end
end
