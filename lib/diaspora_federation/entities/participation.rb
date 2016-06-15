module DiasporaFederation
  module Entities
    # participation is sent to subscribe a user on updates for some post
    #
    # @see Validators::Participation
    class Participation < Entity
      # old signature order
      # @deprecated
      LEGACY_SIGNATURE_ORDER = %i(guid parent_type parent_guid author).freeze

      include Relayable

      # @!attribute [r] parent_type
      #   a string describing a type of the target to subscribe on.
      #   currently only "Post" is supported.
      #   @return [String] parent type
      property :parent_type, xml_name: :target_type

      # It is only valid to receive a {Participation} from the author itself.
      # @deprecated remove after {Participation} doesn't include {Relayable} anymore
      def sender_valid?(sender)
        sender == author
      end

      # Default implementation, don't verify signatures for a {Participation}.
      # @see Entity.populate_entity
      # @deprecated remove after {Participation} doesn't include {Relayable} anymore
      # @param [Nokogiri::XML::Element] root_node xml nodes
      # @return [Entity] instance
      def self.populate_entity(root_node)
        new(entity_data(root_node).merge(parent: nil))
      end
      private_class_method :populate_entity
    end
  end
end
