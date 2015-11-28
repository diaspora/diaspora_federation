module DiasporaFederation
  module Validators
    # This validates a {Entities::Poll}
    class PollValidator < Validation::Validator
      include Validation

      rule :guid, :guid
      rule :question, [:not_empty, length: {maximum: 255}]
    end
  end
end
