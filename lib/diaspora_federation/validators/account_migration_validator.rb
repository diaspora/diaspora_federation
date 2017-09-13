module DiasporaFederation
  module Validators
    # This validates a {Entities::AccountMigration}.
    class AccountMigrationValidator < OptionalAwareValidator
      include Validation

      rule :author, :diaspora_id

      rule :profile, :not_nil
    end
  end
end
