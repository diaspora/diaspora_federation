module DiasporaFederation
  module Entities
    # this entity represents a participation in poll, i.e. it is issued when a user votes for an answer in a poll
    #
    # @see Validators::PollParticipationValidator
    class PollParticipation < Entity
      # @!attribute [r] guid
      #   a random string of at least 16 chars.
      #   @see Validation::Rule::Guid
      #   @return [String] guid
      property :guid

      include Relayable

      # @!attribute [r] diaspora_id
      #   The diaspora ID of the person who voted in the poll
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      property :diaspora_id, xml_name: :diaspora_handle

      # @!attribute [r] poll_answer_guid
      #   guid of the answer selected by the user.
      #   @see PollAnswer#guid
      #   @return [String] poll answer guid
      property :poll_answer_guid
    end
  end
end
