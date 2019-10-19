# frozen_string_literal: true

module DiasporaFederation
  module Entities
    # This entity represents a participation in an event, i.e. it is issued when a user responds to en event.
    #
    # @see Validators::EventParticipationValidator
    class EventParticipation < Entity
      # The {EventParticipation} parent is an {Event}
      PARENT_TYPE = "Event"

      include Relayable

      # @!attribute [r] status
      #   The participation status of the user
      #   "accepted", "declined" or "tentative"
      #   @return [String] event participation status
      property :status, :string

      # @!attribute [r] edited_at
      #   The timestamp when the event participation was edited
      #   @return [Time] edited time
      property :edited_at, :timestamp, optional: true
    end
  end
end
