module DiasporaFederation
  module Validators
    # This validates a {Entities::AccountMigration}.
    class AccountMigrationValidator < OptionalAwareValidator
      include Validation

      rule :author, :diaspora_id

      rule :profile, :not_nil

      rule :old_identity, :diaspora_id
    end
  end
end
