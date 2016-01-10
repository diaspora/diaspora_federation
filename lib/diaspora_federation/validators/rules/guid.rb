module Validation
  module Rule
    # GUID validation rule
    #
    # Valid is a +String+ that is at least 16 chars long and contains only:
    # * Letters: a-z
    # * Numbers: 0-9
    # * Special chars: '-', '_', '@', '.' and ':'
    class Guid
      # This rule can have a +nilable+ param
      # @return [Hash] params
      attr_reader :params

      # create a new rule for guid validation
      # @param [Hash] params
      # @option params [Boolean] :nilable guid allowed to be nil
      def initialize(params={})
        if params.include?(:nilable) && !params[:nilable].is_a?(TrueClass) && !params[:nilable].is_a?(FalseClass)
          raise ArgumentError, ":nilable needs to be a boolean"
        end

        @params = params
      end

      # The error key for this rule
      # @return [Symbol] error key
      def error_key
        :guid
      end

      # Determines if value is a valid +GUID+
      def valid_value?(value)
        params[:nilable] && value.nil? || value.is_a?(String) && value.downcase =~ /\A[0-9a-z\-_@.:]{16,}\z/
      end
    end
  end
end
