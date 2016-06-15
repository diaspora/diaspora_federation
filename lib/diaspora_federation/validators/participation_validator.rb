module DiasporaFederation
  module Validators
    # This validates a {Entities::Participation}
    class ParticipationValidator < Validation::Validator
      include Validation

      rule :author, %i(not_empty diaspora_id)
      rule :guid, :guid
      rule :parent_guid, :guid
      rule :parent_type, [:not_empty, regular_expression: {regex: /\APost\z/}]
    end
  end
end
