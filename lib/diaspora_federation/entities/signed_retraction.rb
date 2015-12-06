module DiasporaFederation
  module Entities
    # this entity represents a claim of deletion of a previously federated
    # entity of post type ({Entities::StatusMessage})
    #
    # @see Validators::SignedRetractionValidator
    # @deprecated will be replaced with {Entities::Retraction}
    class SignedRetraction < Entity
      # @!attribute [r] target_guid
      #   guid of a post to be deleted
      #   @see HCard#guid
      #   @return [String] target guid
      property :target_guid

      # @!attribute [r] target_type
      #   @return [String] target type
      property :target_type

      # @!attribute [r] diaspora_id
      #   The diaspora ID of the person who deletes a post
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      property :diaspora_id, xml_name: :sender_handle

      # @!attribute [r] author_signature
      #   Contains a signature of the entity using the private key of the author of a post
      #   This signature is mandatory.
      #   @return [String] author signature
      property :target_author_signature, default: nil

      # Generates XML and updates signatures
      # @see Entity#to_xml
      # @return [Nokogiri::XML::Element] root element containing properties as child elements
      def to_xml
        entity_xml.tap do |xml|
          hash = to_h
          SignedRetraction.update_signatures!(hash)

          xml.at_xpath("target_author_signature").content = hash[:target_author_signature]
        end
      end

      # Adds signature to a given hash with the key of the author
      # if the signature is not in the hash yet and if the key is available.
      #
      # @param [Hash] data hash given for a signing
      def self.update_signatures!(data)
        if data[:target_author_signature].nil?
          pkey = DiasporaFederation.callbacks.trigger(:fetch_private_key_by_diaspora_id, data[:diaspora_id])
          data[:target_author_signature] = Signing.sign_with_key(apply_signable_exceptions(data), pkey) unless pkey.nil?
        end
      end

      # Deletes :diaspora_id (xml_name: sender_handle) from the hash in order to compute
      # a signature since it is included from signable_string for SignedRetraction and RelayableRetraction
      #
      # @param [Hash] data hash of the retraction properties
      # @retrun [Hash] hash copy without :diaspora_id member
      def self.apply_signable_exceptions(data)
        data.dup.tap {|data| data.delete(:diaspora_id) }
      end
    end
  end
end
