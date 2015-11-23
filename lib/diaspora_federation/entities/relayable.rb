module DiasporaFederation
  module Entities
    # this is a module that defines common properties for relayable entities
    # which include Like, Comment, Participation, Message, etc. Each relayable
    # has a parent, identified by guid. Relayables also are signed and signing/verificating
    # logic is embedded into Salmon XML processing code.
    module Relayable
      # on inclusion of this module the required properties for a relayable are added to the object that includes it
      def self.included(model)
        model.class_eval do
          # @!attribute [r] parent_guid
          #   @see HCard#guid
          #   @return [String] parent guid
          property :parent_guid

          # @!attribute [r] parent_author_signature
          #   Contains a signature of the entity using the private key of the author of a parent post
          #   This signature is required only when federation from upstream (parent) post author to
          #   downstream subscribers. This is the case when the parent author has to resend a relayable
          #   received from one of his subscribers to all others.
          #
          #   @return [String] parent author signature
          property :parent_author_signature, default: nil

          # @!attribute [r] author_signature
          #   Contains a signature of the entity using the private key of the author of a post itself.
          #   The presence of this signature is mandatory. Without it the entity won't be accepted by
          #   a target pod.
          #   @return [String] author signature
          property :author_signature, default: nil
        end
      end

      # Generates XML and updates signatures
      def to_xml
        xml = entity_xml
        hash = to_h
        Relayable.update_signatures!(hash)

        xml.at_xpath("author_signature").content = hash[:author_signature]
        xml.at_xpath("parent_author_signature").content = hash[:parent_author_signature]
        xml
      end

      # Exception raised when verify_signatures fails to verify signatures (signatures are wrong)
      class SignatureVerificationFailed < ArgumentError
      end

      def self.verify_signatures(data)
        pkey = DiasporaFederation.callbacks.trigger(:fetch_public_key_by_id, data[:diaspora_id])
        raise SignatureVerificationFailed, "failed to fetch public key for #{data[:diaspora_id]}" if pkey.nil?
        raise SignatureVerificationFailed, "wrong author_signature" unless Signing.verify_signature(
          data, data[:author_signature], pkey
        )

        unless DiasporaFederation.callbacks.trigger(:post_author_is_local?, data[:parent_guid])
          # this happens only on downstream federation
          pkey = DiasporaFederation.callbacks.trigger(:fetch_public_key_by_post_guid, data[:parent_guid])
          raise SignatureVerificationFailed,
                "failed to fetch public key for parent of #{data[:parent_guid]}" if pkey.nil?
          raise SignatureVerificationFailed, "wrong parent_author_signature" unless Signing.verify_signature(
            data, data[:parent_author_signature], pkey
          )
        end
      end

      # Adds signatures to a given hash with the keys of the author and the parent
      # if the signatures are not in the hash yet and if the keys are available.
      #
      # @param [Hash] data hash given for a signing
      # @return [Hash] reference to the input hash
      def self.update_signatures!(data)
        if data[:author_signature].nil?
          pkey = DiasporaFederation.callbacks.trigger(:fetch_private_key_by_id, data[:diaspora_id])
          data[:author_signature] = Signing.sign_with_key(data, pkey) unless pkey.nil?
        end

        if data[:parent_author_signature].nil?
          pkey = DiasporaFederation.callbacks.trigger(:fetch_private_key_by_post_guid, data[:parent_guid])
          data[:parent_author_signature] = Signing.sign_with_key(data, pkey) unless pkey.nil?
        end

        data
      end
    end
  end
end
