module DiasporaFederation
  module Entities
    # this is a module that defines common properties for relayable entities
    # which include Like, Comment, Participation, Message, etc. Each relayable
    # has a parent, identified by guid. Relayables also are signed and signing/verification
    # logic is embedded into Salmon XML processing code.
    module Relayable
      include Logging

      # digest instance used for signing
      DIGEST = OpenSSL::Digest::SHA256.new

      # on inclusion of this module the required properties for a relayable are added to the object that includes it
      #
      # @!attribute [r] diaspora_id
      #   The diaspora ID of the author.
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      #
      # @!attribute [r] guid
      #   a random string of at least 16 chars.
      #   @see Validation::Rule::Guid
      #   @return [String] comment guid
      #
      # @!attribute [r] parent_guid
      #   @see StatusMessage#guid
      #   @return [String] parent guid
      #
      # @!attribute [r] author_signature
      #   Contains a signature of the entity using the private key of the author of a post itself.
      #   The presence of this signature is mandatory. Without it the entity won't be accepted by
      #   a target pod.
      #   @return [String] author signature
      #
      # @!attribute [r] parent_author_signature
      #   Contains a signature of the entity using the private key of the author of a parent post
      #   This signature is required only when federation from upstream (parent) post author to
      #   downstream subscribers. This is the case when the parent author has to resend a relayable
      #   received from one of his subscribers to all others.
      #
      #   @return [String] parent author signature
      #
      # @param [Entity] entity the entity in which it is included
      def self.included(entity)
        entity.class_eval do
          property :diaspora_id, xml_name: :diaspora_handle
          property :guid
          property :parent_guid
          property :author_signature, default: nil
          property :parent_author_signature, default: nil
        end
      end

      # Adds signatures to the hash with the keys of the author and the parent
      # if the signatures are not in the hash yet and if the keys are available.
      #
      # @see Entity#to_h
      # @return [Hash] entity data hash with updated signatures
      def to_signed_h
        to_h.tap do |hash|
          if author_signature.nil?
            privkey = DiasporaFederation.callbacks.trigger(:fetch_private_key_by_diaspora_id, diaspora_id)
            raise AuthorPrivateKeyNotFound, "author=#{diaspora_id} guid=#{guid}" if privkey.nil?
            hash[:author_signature] = sign_with_key(privkey, hash)
            logger.info "event=sign_with_key signature=author_signature author=#{diaspora_id} guid=#{guid}"
          end

          try_sign_with_parent_author(hash) if parent_author_signature.nil?
        end
      end

      # Generates XML and updates signatures
      # @see Entity#to_xml
      # @return [Nokogiri::XML::Element] root element containing properties as child elements
      def to_xml
        entity_xml.tap do |xml|
          hash = to_signed_h
          xml.at_xpath("author_signature").content = hash[:author_signature]
          xml.at_xpath("parent_author_signature").content = hash[:parent_author_signature]
        end
      end

      # verifies the signatures (+author_signature+ and +parent_author_signature+ if needed)
      # @raise [SignatureVerificationFailed] if the signature is not valid or no public key is found
      def verify_signatures
        pubkey = DiasporaFederation.callbacks.trigger(:fetch_public_key_by_diaspora_id, diaspora_id)
        raise PublicKeyNotFound, "author_signature author=#{diaspora_id} guid=#{guid}" if pubkey.nil?
        raise SignatureVerificationFailed, "wrong author_signature" unless verify_signature(pubkey, author_signature)

        parent_author_local = DiasporaFederation.callbacks.trigger(:entity_author_is_local?, parent_type, parent_guid)
        verify_parent_author_signature unless parent_author_local
      end

      private

      # sign with parent author, if the parent author is local (if the private key is found)
      # @param [Hash] hash the hash to sign
      def try_sign_with_parent_author(hash)
        privkey = DiasporaFederation.callbacks.trigger(
          :fetch_author_private_key_by_entity_guid, parent_type, parent_guid
        )
        unless privkey.nil?
          hash[:parent_author_signature] = sign_with_key(privkey, hash)
          logger.info "event=sign_with_key signature=parent_author_signature guid=#{guid}"
        end
      end

      # this happens only on downstream federation
      def verify_parent_author_signature
        pubkey = DiasporaFederation.callbacks.trigger(:fetch_author_public_key_by_entity_guid, parent_type, parent_guid)

        raise PublicKeyNotFound, "parent_author_signature parent_guid=#{parent_guid} guid=#{guid}" if pubkey.nil?
        unless verify_signature(pubkey, parent_author_signature)
          raise SignatureVerificationFailed, "wrong parent_author_signature parent_guid=#{parent_guid}"
        end
      end

      # Sign the data with the key
      #
      # @param [OpenSSL::PKey::RSA] privkey An RSA key
      # @param [Hash] hash data to sign
      # @return [String] A Base64 encoded signature of #signable_string with key
      def sign_with_key(privkey, hash)
        Base64.strict_encode64(privkey.sign(DIGEST, legacy_signature_data(hash)))
      end

      # Check that signature is a correct signature
      #
      # @param [OpenSSL::PKey::RSA] pubkey An RSA key
      # @param [String] signature The signature to be verified.
      # @return [Boolean]
      def verify_signature(pubkey, signature)
        if signature.nil?
          logger.warn "event=verify_signature status=abort reason=no_signature guid=#{guid}"
          return false
        end

        validity = pubkey.verify(DIGEST, Base64.decode64(signature), legacy_signature_data(to_h))
        logger.info "event=verify_signature status=complete guid=#{guid} validity=#{validity}"
        validity
      end

      # @param [Hash] hash data to sign
      # @return [String] signature data string
      # @deprecated
      def legacy_signature_data(hash)
        self.class::LEGACY_SIGNATURE_ORDER.map {|name| hash[name] }.join(";")
      end

      # Exception raised when creating the author_signature failes, because the private key was not found
      class AuthorPrivateKeyNotFound < RuntimeError
      end

      # Exception raised when verify_signatures fails to verify signatures (no public key found)
      class PublicKeyNotFound < RuntimeError
      end

      # Exception raised when verify_signatures fails to verify signatures (signatures are wrong)
      class SignatureVerificationFailed < RuntimeError
      end
    end
  end
end
