module DiasporaFederation
  module Entities
    # This entity represents a poll and it is federated as an optional part of a status message.
    #
    # @see Validators::PollValidator
    class Poll < Entity
      # @!attribute [r] guid
      #   A random string of at least 16 chars
      #   @see Validation::Rule::Guid
      #   @return [String] poll guid
      property :guid, :string

      # @!attribute [r] question
      #   Text of the question posed by a user
      #   @return [String] question
      property :question, :string

      # @!attribute [r] poll_answers
      #   Array of possible answers for the poll
      #   @return [[Entities::PollAnswer]] poll answers
      entity :poll_answers, [Entities::PollAnswer]
    end
  end
end
