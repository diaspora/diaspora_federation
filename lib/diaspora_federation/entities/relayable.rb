module DiasporaFederation
  module Entities
    # this is a module that defines common properties for relayable entities
    # which include Like, Comment, Participation, Message, etc. Each relayable
    # has a parent, identified by guid. Relayables also are signed and signing/verificating
    # logic is embedded into Salmon XML processing code.
    module Relayable
      # on inclusion of this module the required properties for a relayable are added to the object that includes it
      #
      # @!attribute [r] parent_guid
      #   @see StatusMessage#guid
      #   @return [String] parent guid
      #
      # @!attribute [r] parent_author_signature
      #   Contains a signature of the entity using the private key of the author of a parent post
      #   This signature is required only when federation from upstream (parent) post author to
      #   downstream subscribers. This is the case when the parent author has to resend a relayable
      #   received from one of his subscribers to all others.
      #
      #   @return [String] parent author signature
      #
      # @!attribute [r] author_signature
      #   Contains a signature of the entity using the private key of the author of a post itself.
      #   The presence of this signature is mandatory. Without it the entity won't be accepted by
      #   a target pod.
      #   @return [String] author signature
      #
      # @param [Entity] entity the entity in which it is included
      def self.included(entity)
        entity.class_eval do
          property :parent_guid
          property :parent_author_signature, default: nil
          property :author_signature, default: nil
        end
      end

      # Adds signatures to the hash with the keys of the author and the parent
      # if the signatures are not in the hash yet and if the keys are available.
      #
      # @return [Hash] entity data hash with updated signatures
      def to_signed_h
        to_h.tap do |hash|
          if author_signature.nil?
            privkey = DiasporaFederation.callbacks.trigger(:fetch_private_key_by_diaspora_id, diaspora_id)
            hash[:author_signature] = Signing.sign_with_key(hash, privkey) unless privkey.nil?
          end

          if parent_author_signature.nil?
            privkey = DiasporaFederation.callbacks.trigger(
              :fetch_author_private_key_by_entity_guid, target_type, parent_guid
            )
            hash[:parent_author_signature] = Signing.sign_with_key(hash, privkey) unless privkey.nil?
          end
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

      # Exception raised when verify_signatures fails to verify signatures (signatures are wrong)
      class SignatureVerificationFailed < ArgumentError
      end

      # verifies the signatures (+author_signature+ and +parent_author_signature+ if needed)
      # @raise [SignatureVerificationFailed] if the signature is not valid or no public key is found
      def verify_signatures
        pubkey = DiasporaFederation.callbacks.trigger(:fetch_public_key_by_diaspora_id, diaspora_id)
        raise SignatureVerificationFailed, "failed to fetch public key for #{diaspora_id}" if pubkey.nil?
        raise SignatureVerificationFailed, "wrong author_signature" unless Signing.verify_signature(
          data, author_signature, pubkey
        )

        author_is_local = DiasporaFederation.callbacks.trigger(:entity_author_is_local?, target_type, parent_guid)
        verify_parent_signature unless author_is_local
      end

      private

      # this happens only on downstream federation
      def verify_parent_signature
        pubkey = DiasporaFederation.callbacks.trigger(:fetch_author_public_key_by_entity_guid, target_type, parent_guid)

        raise SignatureVerificationFailed, "failed to fetch public key for author of #{parent_guid}" if pubkey.nil?
        raise SignatureVerificationFailed, "wrong parent_author_signature" unless Signing.verify_signature(
          data, parent_author_signature, pubkey
        )
      end
    end
  end
end
