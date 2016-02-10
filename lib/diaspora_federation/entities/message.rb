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

      # The {Message} parent is a {Conversation}
      # @return [String] parent type
      def parent_type
        "Conversation"
      end
    end
  end
end
