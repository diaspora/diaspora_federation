module DiasporaFederation
  module Entities
    # This entity is sent when an account was deleted on a remote pod.
    #
    # @see Validators::AccountDeletionValidator
    class AccountDeletion < Entity
      # @!attribute [r] author
      #   The diaspora* ID of the deleted account
      #   @see Person#author
      #   @return [String] diaspora* ID
      # @!attribute [r] diaspora_id
      #   Alias for author
      #   @see AccountDeletion#author
      #   @return [String] diaspora* ID
      property :author, :string, alias: :diaspora_id, xml_name: :diaspora_handle

      # @return [String] string representation of this object
      def to_s
        "AccountDeletion:#{author}"
      end
    end
  end
end
