module DiasporaFederation
  module Entities
    # This entity represents a claim of deletion of a previously federated
    # entity of post type. ({Entities::StatusMessage})
    #
    # @see Validators::SignedRetractionValidator
    # @deprecated will be replaced with {Entities::Retraction}
    class SignedRetraction < Entity
      # @!attribute [r] target_guid
      #   Guid of a post to be deleted
      #   @see Retraction#target_guid
      #   @return [String] target guid
      property :target_guid, :string

      # @!attribute [r] target_type
      #   A string describing the type of the target
      #   @see Retraction#target_type
      #   @return [String] target type
      property :target_type, :string

      # @!attribute [r] author
      #   The diaspora* ID of the person who deletes a post
      #   @see Person#author
      #   @return [String] diaspora* ID
      property :author, :string, xml_name: :sender_handle

      # @!attribute [r] author_signature
      #   Contains a signature of the entity using the private key of the author of a post
      #   This signature is mandatory.
      #   @return [String] author signature
      property :target_author_signature, :string, default: nil

      # @!attribute [r] target
      #   Target entity
      #   @return [RelatedEntity] target entity
      entity :target, Entities::RelatedEntity

      # Use only {Retraction} for receive
      # @return [Retraction] instance as normal retraction
      def to_retraction
        Retraction.new(author: author, target_guid: target_guid, target_type: target_type, target: target)
      end

      # Create signature for a retraction
      # @param [OpenSSL::PKey::RSA] privkey private key of sender
      # @param [SignedRetraction, RelayableRetraction] ret the retraction to sign
      # @return [String] a Base64 encoded signature of the retraction with the key
      def self.sign_with_key(privkey, ret)
        Base64.strict_encode64(privkey.sign(Relayable::DIGEST, [ret.target_guid, ret.target_type].join(";")))
      end

      # @return [String] string representation of this object
      def to_s
        "SignedRetraction:#{target_type}:#{target_guid}"
      end

      # @return [Retraction] instance
      def self.from_hash(hash)
        hash[:target] = Retraction.send(:fetch_target, hash[:target_type], hash[:target_guid])
        new(hash).to_retraction
      end

      private

      # It updates also the signatures with the keys of the author and the parent
      # if the signatures are not there yet and if the keys are available.
      #
      # @return [Hash] xml elements with updated signatures
      def enriched_properties
        super.tap do |hash|
          hash[:target_author_signature] = target_author_signature || sign_with_author.to_s
        end
      end

      def sign_with_author
        privkey = DiasporaFederation.callbacks.trigger(:fetch_private_key, author)
        SignedRetraction.sign_with_key(privkey, self) unless privkey.nil?
      end
    end
  end
end
