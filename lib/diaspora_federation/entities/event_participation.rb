module DiasporaFederation
  module Entities
    # This entity represents a participation in an event, i.e. it is issued when a user responds to en event.
    #
    # @see Validators::EventParticipationValidator
    class EventParticipation < Entity
      # The {EventParticipation} parent is an {Event}
      PARENT_TYPE = "Event".freeze

      include Relayable

      # Redefine the author property without +diaspora_handle+ +xml_name+
      # @deprecated Can be removed after XMLs are generated with new names
      property :author, :string

      # @!attribute [r] status
      #   The participation status of the user
      #   "accepted", "declined" or "tentative"
      #   @return [String] event participation status
      property :status, :string
    end
  end
end
