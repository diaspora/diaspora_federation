module DiasporaFederation
  module Entities
    # this entity represents a private conversation between users
    #
    # @see Validators::ConversationValidator
    class Conversation < Entity
      # @!attribute [r] guid
      #   a random string of at least 16 chars.
      #   @see Validation::Rule::Guid
      #   @return [String] conversation guid
      property :guid

      # @!attribute [r] subject
      #   @return [String] the conversation subject
      property :subject

      # @!attribute [r] created_at
      #   @return [Time] Conversation creation time
      property :created_at, default: -> { Time.now.utc }

      # @!attribute [r] messages
      #   @return [[Entities::Message]] Messages of this conversation
      entity :messages, [Entities::Message]

      # @!attribute [r] diaspora_id
      #   The diaspora ID of the person initiated the conversation.
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      property :diaspora_id, xml_name: :diaspora_handle

      # @!attribute [r] participant_ids
      #   The diaspora IDs of the persons participating the conversation separated by ";".
      #   @see Person#diaspora_id
      #   @return [String] participants diaspora IDs
      property :participant_ids, xml_name: :participant_handles
    end
  end
end
