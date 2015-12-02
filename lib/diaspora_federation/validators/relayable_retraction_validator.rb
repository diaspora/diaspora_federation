module DiasporaFederation
  module Validators
    # This validates a {Entities::RelayableRetraction}
    class RelayableRetractionValidator < Validation::Validator
      include Validation

      rule :target_guid, :guid

      rule :target_type, :not_empty

      rule :diaspora_id, %i(not_empty diaspora_id)
    end
  end
end
