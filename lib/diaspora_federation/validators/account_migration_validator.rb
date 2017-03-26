module DiasporaFederation
  module Validators
    # This validates a {Entities::AccountMigration}.
    class AccountMigrationValidator < Validation::Validator
      include Validation

      rule :author, %i(not_empty diaspora_id)

      rule :profile, :not_nil
    end
  end
end
