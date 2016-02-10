module DiasporaFederation
  module Validators
    # This validates a {Entities::AccountDeletion}
    class AccountDeletionValidator < Validation::Validator
      include Validation

      rule :author, %i(not_empty diaspora_id)
    end
  end
end
