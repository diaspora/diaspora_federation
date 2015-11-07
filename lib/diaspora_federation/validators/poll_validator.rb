module DiasporaFederation
  module Validators
    class PollValidator < Validation::Validator
      include Validation

      rule :guid, :guid
      rule :question, [:not_empty, length: {maximum: 255}]
    end
  end
end
