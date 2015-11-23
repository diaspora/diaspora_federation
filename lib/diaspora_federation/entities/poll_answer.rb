module DiasporaFederation
  module Entities
    # this entity represents a poll answer and is federated as a part of the Poll entity
    #
    # @see Validators::PollAnswerValidator
    class PollAnswer < Entity
      # @!attribute [r] guid
      #   @see HCard#guid
      #   @return [String] guid
      property :guid

      # @!attribute [r] answer
      #   Text of the answer
      #   @return [String] answer
      property :answer
    end
  end
end
