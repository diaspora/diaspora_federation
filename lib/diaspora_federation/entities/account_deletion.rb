module DiasporaFederation
  module Entities
    # this entity is sent when account was deleted on a remote pod
    #
    # @see Validators::AccountDeletionValidator
    class AccountDeletion < Entity
      # @!attribute [r] author
      #   The diaspora ID of the deleted account
      #   @see Person#author
      #   @return [String] diaspora ID
      property :author, xml_name: :diaspora_handle
    end
  end
end
