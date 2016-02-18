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
      #   @see Retraction#target_guid
      #   @return [String] target guid
      property :target_guid

      # @!attribute [r] target_type
      #   A string describing the type of the target.
      #   @see Retraction#target_type
      #   @return [String] target type
      property :target_type

      # @!attribute [r] author
      #   The diaspora ID of the person who deletes a post
      #   @see Person#author
      #   @return [String] diaspora ID
      property :author, xml_name: :sender_handle

      # @!attribute [r] author_signature
      #   Contains a signature of the entity using the private key of the author of a post
      #   This signature is mandatory.
      #   @return [String] author signature
      property :target_author_signature, default: nil

      # Generates XML and updates signatures
      # @see Entity#to_xml
      # @return [Nokogiri::XML::Element] root element containing properties as child elements
      def to_xml
        super.tap do |xml|
          xml.at_xpath("target_author_signature").content = to_h[:target_author_signature]
        end
      end

      # Adds signature to the hash with the key of the author
      # if the signature is not in the hash yet and if the key is available.
      #
      # @see Entity#to_h
      # @return [Hash] entity data hash with updated signatures
      def to_h
        super.tap do |hash|
          if target_author_signature.nil?
            privkey = DiasporaFederation.callbacks.trigger(:fetch_private_key_by_diaspora_id, author)
            hash[:target_author_signature] = SignedRetraction.sign_with_key(privkey, self) unless privkey.nil?
          end
        end
      end

      # use only {Retraction} for receive
      # @return [Retraction] instance as normal retraction
      def to_retraction
        Retraction.new(author: author, target_guid: target_guid, target_type: target_type)
      end

      # Create signature for a retraction
      # @param [OpenSSL::PKey::RSA] privkey private key of sender
      # @param [SignedRetraction, RelayableRetraction] ret the retraction to sign
      # @return [String] a Base64 encoded signature of the retraction with the key
      def self.sign_with_key(privkey, ret)
        Base64.strict_encode64(privkey.sign(Relayable::DIGEST, [ret.target_guid, ret.target_type].join(";")))
      end
    end
  end
end
