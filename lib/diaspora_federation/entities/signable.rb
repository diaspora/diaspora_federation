module DiasporaFederation
  module Entities
    # Signable is a module that encapsulates basic signature generation/verification flow for entities.
    module Signable
      include Logging

      # Digest instance used for signing
      DIGEST = OpenSSL::Digest::SHA256.new

      # Sign the data with the key
      #
      # @param [OpenSSL::PKey::RSA] privkey An RSA key
      # @return [String] A Base64 encoded signature of #signature_data with key
      def sign_with_key(privkey)
        Base64.strict_encode64(privkey.sign(DIGEST, signature_data))
      end

      # Check that signature is a correct signature
      #
      # @param [String] author The author of the signature
      # @param [String] signature_key The signature to be verified
      # @raise [SignatureVerificationFailed] if the signature is not valid
      # @raise [PublicKeyNotFound] if no public key is found
      def verify_signature(author, signature_key)
        pubkey = DiasporaFederation.callbacks.trigger(:fetch_public_key, author)
        raise PublicKeyNotFound, "signature=#{signature_key} person=#{author} obj=#{self}" if pubkey.nil?

        signature = public_send(signature_key)
        raise SignatureVerificationFailed, "no #{signature_key} for #{self}" if signature.nil?

        valid = pubkey.verify(DIGEST, Base64.decode64(signature), signature_data)
        raise SignatureVerificationFailed, "wrong #{signature_key} for #{self}" unless valid

        logger.info "event=verify_signature signature=#{signature_key} status=valid obj=#{self}"
      end

      # This method defines what data is used for a signature creation/verification
      #
      # @abstract
      # @return [String] a string to sign
      def signature_data
        raise NotImplementedError.new("you must override this method to define signature base string")
      end

      # Raised, if verify_signatures fails to verify signatures (no public key found)
      class PublicKeyNotFound < RuntimeError
      end

      # Raised, if verify_signatures fails to verify signatures (signatures are wrong)
      class SignatureVerificationFailed < RuntimeError
      end
    end
  end
end
