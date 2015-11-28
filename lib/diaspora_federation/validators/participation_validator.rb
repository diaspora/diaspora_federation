module DiasporaFederation
  module Validators
    # This validates a {Entities::Participation}
    class ParticipationValidator < Validation::Validator
      include Validation

      rule :guid, :guid

      rule :target_type, :not_empty

      include RelayableValidator

      rule :diaspora_id, %i(not_empty diaspora_id)
    end
  end
end
