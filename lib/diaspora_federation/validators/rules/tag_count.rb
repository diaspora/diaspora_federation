module Validation
  module Rule
    # Rule for validating the number of tags in a string.
    # Only the "#" characters will be counted.
    class TagCount
      attr_reader :params

      # @param [Hash] params
      # @option params [Fixnum] :maximum maximum allowed tag count
      def initialize(params)
        unless params.include?(:maximum) && params[:maximum].is_a?(Fixnum)
          raise ArgumentError, "A number has to be specified for :maximum"
        end

        @params = params
      end

      def error_key
        :tag_count
      end

      def valid_value?(value)
        value.nil? || value.count("#") <= params[:maximum]
      end
    end
  end
end
