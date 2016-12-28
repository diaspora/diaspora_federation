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

      # Validates that the parent exists and the parent author is local
      def validate_parent
        parent = DiasporaFederation.callbacks.trigger(:fetch_related_entity, parent_type, parent_guid)
        raise ParentNotLocal, "obj=#{self}" unless parent && parent.local
      end

      # Don't verify signatures for a {Participation}. Validate that the parent is local.
      # @see Entity.populate_entity
      # @param [Nokogiri::XML::Element] root_node xml nodes
      # @return [Entity] instance
      private_class_method def self.populate_entity(root_node)
        new(entity_data(root_node).merge(parent: nil)).tap(&:validate_parent)
      end

      # Raised, if the parent is not owned by the receiving pod.
      class ParentNotLocal < RuntimeError
      end
    end
  end
end
