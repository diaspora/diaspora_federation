module DiasporaFederation
  module Validators
    # This validates a {Entities::Participation}
    class ParticipationValidator < Validation::Validator
      include Validation

      include RelayableValidator

      rule :parent_type, [:not_empty, regular_expression: {regex: /\APost\z/}]
    end
  end
end
