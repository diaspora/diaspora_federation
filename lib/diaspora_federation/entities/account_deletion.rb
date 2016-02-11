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
      # @!attribute [r] diaspora_id
      #   Alias for author
      #   @see AccountDeletion#author
      #   @return [String] diaspora ID
      property :author, alias: :diaspora_id, xml_name: :diaspora_handle
    end
  end
end
