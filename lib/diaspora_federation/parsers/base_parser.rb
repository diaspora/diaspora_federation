module DiasporaFederation
  module Parsers
    # +BaseParser+ is an abstract class which is used for defining parsers for different
    # deserialization methods.
    class BaseParser
      # @param [Class] entity_type type of DiasporaFederation::Entity that we want to parse with that parser instance
      def initialize(entity_type)
        @entity_type = entity_type
      end

      # This method is used to parse input with a serialized object data. It returns
      # a comprehensive data which must be enough to construct a DiasporaFederation::Entity instance.
      #
      # Since parser method output is normally passed to a .from_hash method of an entity
      # as arguments using * operator, the parse method must return an array of a size matching the number
      # of arguments of .from_hash method of the entity type we link with
      # @abstract
      def parse(*)
        raise NotImplementedError.new("you must override this method when creating your own parser")
      end

      private

      # @param [Symbol] type target type to parse
      # @param [String] text data as string
      # @return [String, Boolean, Integer, Time] data
      def parse_string(type, text)
        case type
        when :timestamp
          begin
            Time.parse(text).utc
          rescue
            nil
          end
        when :integer
          text.to_i if text =~ /\A\d+\z/
        when :boolean
          return true if text =~ /\A(true|t|yes|y|1)\z/i
          false if text =~ /\A(false|f|no|n|0)\z/i
        else
          text
        end
      end

      def assert_parsability_of(entity_class)
        return if entity_class == entity_type.entity_name
        raise InvalidRootNode, "'#{entity_class}' can't be parsed by #{entity_type.name}"
      end

      attr_reader :entity_type

      def class_properties
        entity_type.class_props
      end

      # Raised, if the root node doesn't match the class name
      class InvalidRootNode < RuntimeError
      end
    end
  end
end
