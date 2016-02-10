module DiasporaFederation
  module Validators
    # This validates a {Entities::SignedRetraction}
    # @deprecated the {Entities::RelayableRetraction} will be replaced with {Entities::Retraction}
    class SignedRetractionValidator < Validation::Validator
      include Validation

      rule :target_guid, :guid

      rule :target_type, :not_empty

      rule :author, %i(not_empty diaspora_id)
    end
  end
end
