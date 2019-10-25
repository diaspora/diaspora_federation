# frozen_string_literal: true

module DiasporaFederation
  module Entities
    # This entity represents a poll answer and is federated as a part of the Poll entity.
    #
    # @see Validators::PollAnswerValidator
    class PollAnswer < Entity
      # @!attribute [r] guid
      #   A random string of at least 16 chars
      #   @see Validation::Rule::Guid
      #   @return [String] guid
      property :guid, :string

      # @!attribute [r] answer
      #   Text of the answer
      #   @return [String] answer
      property :answer, :string
    end
  end
end
