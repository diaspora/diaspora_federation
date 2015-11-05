module DiasporaFederation
  module Validators
    class AccountDeletionValidator < Validation::Validator
      include Validation

      rule :diaspora_id, %i(not_empty diaspora_id)
    end
  end
end
