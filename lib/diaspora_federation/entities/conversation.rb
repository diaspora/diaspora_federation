module DiasporaFederation
  module Entities
    # this entity represents a private conversation between users
    #
    # @see Validators::ConverstaionValidator
    class Conversation < Entity
      # @!attribute [r] guid
      #   @see HCard#guid
      #   @return [String] guid
      property :guid

      # @!attribute [r] subject
      #   @return [String] the conversation subject
      property :subject

      # @!attribute [r] created_at
      #   @return [Time] Conversation creation time
      property :created_at, default: -> { Time.now.utc }

      entity :messages, [Entities::Message]

      # @!attribute [r] diaspora_id
      #   The diaspora ID of the person initiated the conversation
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      property :diaspora_id, xml_name: :diaspora_handle

      property :participant_ids, xml_name: :participant_handles
    end
  end
end
