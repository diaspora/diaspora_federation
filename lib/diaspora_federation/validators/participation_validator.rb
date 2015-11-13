module DiasporaFederation
  module Validators
    class ParticipationValidator < Validation::Validator
      include Validation

      rule :guid, :guid

      rule :target_type, :not_empty

      include RelayableValidator

      rule :diaspora_id, %i(not_empty diaspora_id)
    end
  end
end
