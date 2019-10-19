# frozen_string_literal: true

module DiasporaFederation
  module Entities
    # This entity represents a private message exchanged in private conversation.
    #
    # @see Validators::MessageValidator
    class Message < Entity
      # @!attribute [r] author
      #   The diaspora* ID of the author
      #   @see Person#author
      #   @return [String] diaspora* ID
      property :author, :string, xml_name: :diaspora_handle

      # @!attribute [r] guid
      #   A random string of at least 16 chars
      #   @see Validation::Rule::Guid
      #   @return [String] guid
      property :guid, :string

      # @!attribute [r] text
      #   Text of the message composed by a user
      #   @return [String] text
      property :text, :string

      # @!attribute [r] created_at
      #   Message creation time
      #   @return [Time] creation time
      property :created_at, :timestamp, default: -> { Time.now.utc }

      # @!attribute [r] edited_at
      #   The timestamp when the message was edited
      #   @return [Time] edited time
      property :edited_at, :timestamp, optional: true

      # @!attribute [r] conversation_guid
      #   Guid of a conversation this message belongs to
      #   @see Conversation#guid
      #   @return [String] conversation guid
      property :conversation_guid, :string

      # @return [String] string representation of this object
      def to_s
        "#{super}:#{conversation_guid}"
      end
    end
  end
end
