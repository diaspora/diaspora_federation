module DiasporaFederation
  module Entities
    # Participation is sent to subscribe a user on updates for some post.
    #
    # @see Validators::Participation
    class Participation < Entity
      # Old signature order
      # @deprecated
      LEGACY_SIGNATURE_ORDER = %i(guid parent_type parent_guid author).freeze

      include Relayable

      # @!attribute [r] parent_type
      #   A string describing a type of the target to subscribe on
      #   Currently only "Post" is supported.
      #   @return [String] parent type
      property :parent_type, :string, xml_name: :target_type

      # It is only valid to receive a {Participation} from the author themself.
      # @deprecated remove after {Participation} doesn't include {Relayable} anymore
      def sender_valid?(sender)
        sender == author
      end

      # hackaround hacky from_hash override
      # @deprecated remove after {Participation} doesn't include {Relayable} anymore
      def enriched_properties
        super.tap {|hash|
          hash.delete(:parent) if hash[:parent].nil?
        }
      end

      # Validates that the parent exists and the parent author is local
      def validate_parent
        parent = DiasporaFederation.callbacks.trigger(:fetch_related_entity, parent_type, parent_guid)
        raise ParentNotLocal, "obj=#{self}" unless parent && parent.local
      end

      # Don't verify signatures for a {Participation}. Validate that the parent is local.
      # @see Entity.from_hash
      # @param [Hash] hash entity initialization hash
      # @return [Entity] instance
      def self.from_hash(hash)
        new(hash.merge(parent: nil)).tap(&:validate_parent)
      end

      # @deprecated remove after {Participation} doesn't include {Relayable} anymore
      private_class_method def self.xml_parser_class
        DiasporaFederation::Parsers::XmlParser
      end

      # @deprecated remove after {Participation} doesn't include {Relayable} anymore
      private_class_method def self.json_parser_class
        DiasporaFederation::Parsers::JsonParser
      end

      # Raised, if the parent is not owned by the receiving pod.
      class ParentNotLocal < RuntimeError
      end
    end
  end
end
