module DiasporaFederation
  module Entities
    # This entity represents a private message exchanged in private conversation.
    #
    # @see Validators::MessageValidator
    class Message < Entity
      # Old signature order
      # @deprecated
      LEGACY_SIGNATURE_ORDER = %i(guid parent_guid text created_at author conversation_guid).freeze

      include Relayable

      # @!attribute [r] text
      #   Text of the message composed by a user
      #   @return [String] text
      property :text, :string

      # @!attribute [r] created_at
      #   Message creation time
      #   @return [Time] creation time
      property :created_at, :timestamp, default: -> { Time.now.utc }

      # @!attribute [r] conversation_guid
      #   Guid of a conversation this message belongs to
      #   @see Conversation#guid
      #   @return [String] conversation guid
      property :conversation_guid, :string

      # It is only valid to receive a {Message} from the author itself,
      # or from the author of the parent {Conversation} if the author signature is valid.
      # @deprecated remove after {Message} doesn't include {Relayable} anymore
      def sender_valid?(sender)
        sender == author || (sender == parent_author && verify_author_signature)
      end

      private

      # @deprecated remove after {Message} doesn't include {Relayable} anymore
      def verify_author_signature
        verify_signature(author, :author_signature)
        true
      end

      # @deprecated remove after {Message} doesn't include {Relayable} anymore
      def parent_author
        parent = DiasporaFederation.callbacks.trigger(:fetch_related_entity, "Conversation", conversation_guid)
        raise Federation::Fetcher::NotFetchable, "parent of #{self} not found" unless parent
        parent.author
      end

      # old timestamp format, because this signature is only used from old pods which also relay with old format
      # @deprecated remove after {Message} doesn't include {Relayable} anymore
      def normalize_property(name, value)
        if name == :created_at
          value.to_s
        else
          super
        end
      end

      # Default implementation, don't verify signatures for a {Message}.
      # @see Entity.populate_entity
      # @deprecated remove after {Message} doesn't include {Relayable} anymore
      # @param [Nokogiri::XML::Element] root_node xml nodes
      # @return [Entity] instance
      private_class_method def self.populate_entity(root_node)
        new({parent_guid: nil, parent: nil}.merge(entity_data(root_node)))
      end
    end
  end
end
