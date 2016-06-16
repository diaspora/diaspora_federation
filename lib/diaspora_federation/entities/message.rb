module DiasporaFederation
  module Entities
    # this entity represents a private message exchanged in private conversation
    #
    # @see Validators::MessageValidator
    class Message < Entity
      # old signature order
      # @deprecated
      LEGACY_SIGNATURE_ORDER = %i(guid parent_guid text created_at author conversation_guid).freeze

      include Relayable

      # @!attribute [r] text
      #   text of the message composed by a user
      #   @return [String] text
      property :text

      # @!attribute [r] created_at
      #   message creation time
      #   @return [Time] creation time
      property :created_at, default: -> { Time.now.utc }

      # @!attribute [r] conversation_guid
      #   guid of a conversation this message belongs to
      #   @see Conversation#guid
      #   @return [String] conversation guid
      property :conversation_guid

      # It is only valid to receive a {Message} from the author itself,
      # or from the author of the parent {Conversation} if the author signature is valid.
      # @deprecated remove after {Message} doesn't include {Relayable} anymore
      def sender_valid?(sender)
        sender == author || (sender == parent_author && verify_author_signature)
      end

      private

      # @deprecated remove after {Message} doesn't include {Relayable} anymore
      def verify_author_signature
        pubkey = DiasporaFederation.callbacks.trigger(:fetch_public_key, author)
        raise PublicKeyNotFound, "author_signature author=#{author} guid=#{guid}" if pubkey.nil?
        raise SignatureVerificationFailed, "wrong author_signature" unless verify_signature(pubkey, author_signature)
        true
      end

      # @deprecated remove after {Message} doesn't include {Relayable} anymore
      def parent_author
        parent = DiasporaFederation.callbacks.trigger(:fetch_related_entity, "Conversation", conversation_guid)
        raise Federation::Fetcher::NotFetchable, "Conversation:#{conversation_guid} not found" unless parent
        parent.author
      end

      # Default implementation, don't verify signatures for a {Message}.
      # @see Entity.populate_entity
      # @deprecated remove after {Message} doesn't include {Relayable} anymore
      # @param [Nokogiri::XML::Element] root_node xml nodes
      # @return [Entity] instance
      def self.populate_entity(root_node)
        new({parent_guid: nil, parent: nil}.merge(entity_data(root_node)))
      end
      private_class_method :populate_entity
    end
  end
end
