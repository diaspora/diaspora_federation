module DiasporaFederation
  module Entities
    # This entity is sent when a person changes their diaspora* ID (e.g. when a user migration
    # from one to another pod happens).
    #
    # @see Validators::AccountMigrationValidator
    class AccountMigration < Entity
      include AccountMigration::Signable

      # @!attribute [r] author
      #   The old diaspora* ID of the person who changes their ID
      #   @see Person#author
      #   @return [String] author diaspora* ID
      property :author, :string

      # @!attribute [r] profile
      #   Holds new updated profile of a person, including diaspora* ID
      #   @return [Person] person new data
      entity :profile, Entities::Profile

      # @!attribute [r] signature
      #   Signature that validates original and target diaspora* IDs with the new key of person
      #   @return [String] signature
      property :signature, :string, default: nil

      def old_user_id
        author
      end

      # @return [String] string representation of this object
      alias to_s unique_migration_descriptor

      # Shortcut for calling super method with sensible arguments
      #
      # @see DiasporaFederation::Entities::Signable#verify_signature
      def verify_signature
        super(signer_id, :signature)
      end

      # Calls super and additionally does signature verification for the instantiated entity.
      #
      # @see DiasporaFederation::Entity.from_hash
      def self.from_hash(*args)
        super.tap(&:verify_signature)
      end

      private

      def new_user_id
        profile.author
      end

      def signer_id
        new_user_id
      end

      def enriched_properties
        super.tap do |hash|
          hash[:signature] = signature || sign_with_new_key
        end
      end

      # Sign with new user's key
      # @raise [NewPrivateKeyNotFound] if the new user's private key is not found
      # @return [String] A Base64 encoded signature of #signature_data with key
      def sign_with_new_key
        privkey = DiasporaFederation.callbacks.trigger(:fetch_private_key, signer_id)
        raise NewPrivateKeyNotFound, "signer=#{signer_id} obj=#{self}" if privkey.nil?
        sign_with_key(privkey).tap do
          logger.info "event=sign status=complete signature=signature signer=#{signer_id} obj=#{self}"
        end
      end

      # Raised, if creating the signature fails, because the new private key of a user was not found
      class NewPrivateKeyNotFound < RuntimeError
      end
    end
  end
end
