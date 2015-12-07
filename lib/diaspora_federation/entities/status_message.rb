module DiasporaFederation
  module Entities
    # this entity represents a status message sent by a user
    #
    # @see Validators::StatusMessageValidator
    class StatusMessage < Entity
      # @!attribute [r] raw_message
      #   text of the status message composed by the user
      #   @return [String] text of the status message
      property :raw_message

      # @!attribute [r] photos
      #   optional photos attached to the status message
      #   @return [[Entities::Photo]] photos
      entity :photos, [Entities::Photo], default: []

      # @!attribute [r] location
      #   optional location attached to the status message
      #   @return [Entities::Location] location
      entity :location, Entities::Location, default: nil

      # @!attribute [r] poll
      #   optional poll attached to the status message
      #   @return [Entities::Poll] poll
      entity :poll, Entities::Poll, default: nil

      # @!attribute [r] guid
      #   a random string of at least 16 chars.
      #   @see Validation::Rule::Guid
      #   @return [String] status message guid
      property :guid

      # @!attribute [r] diaspora_id
      #   The diaspora ID of the person who posts the status message
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      property :diaspora_id, xml_name: :diaspora_handle

      # @!attribute [r] public
      #   shows whether the status message is visible to everyone or only to some aspects
      #   @return [Boolean] is it public
      property :public, default: false

      # @!attribute [r] created_at
      #   status message entity creation time
      #   @return [Time] creation time
      property :created_at, default: -> { Time.now.utc }

      # @!attribute [r] provider_display_name
      #   a string that describes a means by which a user has posted the status message
      #   @return [String] provider display name
      property :provider_display_name, default: nil
    end
  end
end
