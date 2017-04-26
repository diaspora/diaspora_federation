module DiasporaFederation
  module Entities
    # This entity represents a participation in poll, i.e. it is issued when a user votes for an answer in a poll.
    #
    # @see Validators::PollParticipationValidator
    class PollParticipation < Entity
      # The {PollParticipation} parent is a {Poll}
      PARENT_TYPE = "Poll".freeze

      include Relayable

      # @!attribute [r] poll_answer_guid
      #   Guid of the answer selected by the user
      #   @see PollAnswer#guid
      #   @return [String] poll answer guid
      property :poll_answer_guid, :string
    end
  end
end
