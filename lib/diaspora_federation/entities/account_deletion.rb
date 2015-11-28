module DiasporaFederation
  module Entities
    # this entity is sent when account was deleted on a remote pod
    #
    # @see Validators::AccountDeletionValidator
    class AccountDeletion < Entity
      # @!attribute [r] diaspora_id
      #   The diaspora ID of the deleted account
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      property :diaspora_id, xml_name: :diaspora_handle
    end
  end
end
