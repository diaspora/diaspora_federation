module DiasporaFederation
  module Entities
    # This entity represents a participation in an event, i.e. it is issued when a user responds to en event.
    #
    # @see Validators::EventParticipationValidator
    class EventParticipation < Entity
      # The {EventParticipation} parent is an {Event}
      PARENT_TYPE = "Event".freeze

      include Relayable

      # @!attribute [r] status
      #   The participation status of the user
      #   "accepted", "declined" or "tentative"
      #   @return [String] event participation status
      property :status, :string
    end
  end
end
