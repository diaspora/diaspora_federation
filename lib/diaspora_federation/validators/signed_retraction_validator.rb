module DiasporaFederation
  module Validators
    # This validates a {Entities::SignedRetraction}
    class SignedRetractionValidator < Validation::Validator
      include Validation

      rule :target_guid, :guid

      rule :target_type, :not_empty

      rule :sender_id, %i(not_empty diaspora_id)

      rule :target_author_signature, :not_empty
    end
  end
end
