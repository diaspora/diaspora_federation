module DiasporaFederation
  module Entities
    class AccountMigration < Entity
      # AccountMigration::Signable is a module that encapsulates basic signature generation/verification flow for
      # AccountMigration entity.
      #
      # It is possible that implementation of diaspora* protocol requires to compute the signature for the
      # AccountMigration entity without instantiating the entity. In this case this module may be useful.
      module Signable
        include Entities::Signable

        # @return [String] string which is uniquely represents migration occasion
        def unique_migration_descriptor
          "AccountMigration:#{old_identity}:#{new_identity}"
        end

        # @see DiasporaFederation::Entities::Signable#signature_data
        def signature_data
          unique_migration_descriptor
        end
      end
    end
  end
end
