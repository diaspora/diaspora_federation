module DiasporaFederation
  module Entities
    # this entity represents a private message exchanged in private conversation
    #
    # @see Validators::MessageValidator
    class Message < Entity
      # @!attribute [r] guid
      #   a random string of at least 16 chars.
      #   @see Validation::Rule::Guid
      #   @return [String] message guid
      property :guid

      include Relayable

      # @!attribute [r] text
      #   text of the message composed by a user
      #   @return [String] text
      property :text

      # @!attribute [r] created_at
      #   message creation time
      #   @return [Time] creation time
      property :created_at, default: -> { Time.now.utc }

      # @!attribute [r] diaspora_id
      #   The diaspora ID of the message author.
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      property :diaspora_id, xml_name: :diaspora_handle

      # @!attribute [r] conversation_guid
      #   guid of a conversation this message belongs to
      #   @see Conversation#guid
      #   @return [String] conversation guid
      property :conversation_guid

      # The {Message} parent is a {Conversation}
      # @return [String] parent entity type
      def self.get_target_entity_type(*)
        "Conversation"
      end
    end
  end
end
