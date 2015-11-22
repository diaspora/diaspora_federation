module DiasporaFederation
  module Entities
    module Relayable
      def self.included(model)
        model.class_eval do
          property :parent_guid
          property :parent_author_signature, default: nil
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
