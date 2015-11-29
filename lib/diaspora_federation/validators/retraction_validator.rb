module DiasporaFederation
  module Validators
    # This validates a {Entities::Retraction}
    class RetractionValidator < Validation::Validator
      include Validation

      rule :target_guid, :guid

      rule :diaspora_id, %i(not_empty diaspora_id)

      rule :target_type, :not_empty
    end
  end
end
