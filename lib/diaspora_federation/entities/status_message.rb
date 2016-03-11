module DiasporaFederation
  module Entities
    # this entity represents a status message sent by a user
    #
    # @see Validators::StatusMessageValidator
    class StatusMessage < Entity
      include Post

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

      # @!attribute [r] public
      #   shows whether the status message is visible to everyone or only to some aspects
      #   @return [Boolean] is it public
      property :public, default: false
    end
  end
end
