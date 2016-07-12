module DiasporaFederation
  module Validators
    # This validates a {Entities::PollAnswer}.
    class PollAnswerValidator < Validation::Validator
      include Validation

      rule :guid, :guid
      rule :answer, [:not_empty, length: {maximum: 255}]
    end
  end
end
