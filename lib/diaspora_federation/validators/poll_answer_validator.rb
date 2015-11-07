module DiasporaFederation
  module Validators
    class PollAnswerValidator < Validation::Validator
      include Validation

      rule :guid, :guid
      rule :answer, [:not_empty, length: {maximum: 255}]
    end
  end
end
