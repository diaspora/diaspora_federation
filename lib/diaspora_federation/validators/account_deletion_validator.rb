module DiasporaFederation
  module Validators
    # This validates a {Entities::AccountDeletion}.
    class AccountDeletionValidator < OptionalAwareValidator
      include Validation

      rule :author, :diaspora_id
    end
  end
end
