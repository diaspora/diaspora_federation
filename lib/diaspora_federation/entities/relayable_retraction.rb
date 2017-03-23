module DiasporaFederation
  module Entities
    # This entity represents a claim of deletion of a previously federated
    # relayable entity. ({Entities::Comment}, {Entities::Like})
    #
    # There are two cases of federation of the RelayableRetraction.
    # Retraction from the dowstream object owner is when an author of the
    # relayable (e.g. Comment) deletes it themself. In this case only target_author_signature
    # is filled and a retraction is sent to the commented post's author. Here
    # the upstream object owner signs it with the parent's author key, puts
    # the signature in parent_author_signature and sends it to other pods where
    # other participating people are present. This is the second case - retraction
    # from the upstream object owner.
    # Retraction from the upstream object owner can also be performed by the
    # upstream object owner themself - they have a right to delete comments on their posts.
    # In any case in the retraction by the upstream author target_author_signature
    # is not checked, only parent_author_signature is checked.
    #
    # @see Validators::RelayableRetractionValidator
    # @deprecated will be replaced with {Entities::Retraction}
    class RelayableRetraction < Entity
      # @!attribute [r] parent_author_signature
      #   Contains a signature of the entity using the private key of the author of a parent post.
      #   This signature is mandatory only when federating from an upstream author to the subscribers.
      #   @see Relayable#parent_author_signature
      #   @return [String] parent author signature
      property :parent_author_signature, :string, default: nil

      # @!attribute [r] target_guid
      #   Guid of a relayable to be deleted
      #   @see Comment#guid
      #   @return [String] target guid
      property :target_guid, :string

      # @!attribute [r] target_type
      #   A string describing a type of the target
      #   @see Retraction#target_type
      #   @return [String] target type
      property :target_type, :string

      # @!attribute [r] author
      #   The diaspora* ID of the person who deletes a relayable
      #   @see Person#author
      #   @return [String] diaspora* ID
      property :author, :string, xml_name: :sender_handle

      # @!attribute [r] target_author_signature
      #   Contains a signature of the entity using the private key of the
      #   author of a federated relayable entity. ({Entities::Comment}, {Entities::Like})
      #   This signature is mandatory only when federation from the subscriber to an upstream
      #   author is done.
      #   @see Relayable#author_signature
      #   @return [String] target author signature
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

      # @return [String] string representation of this object
      def to_s
        "RelayableRetraction:#{target_type}:#{target_guid}"
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
        privkey = DiasporaFederation.callbacks.trigger(:fetch_private_key, author)

        super.tap do |hash|
          fill_required_signature(privkey, hash) unless privkey.nil?
        end
      end

      # @param [OpenSSL::PKey::RSA] privkey private key of sender
      # @param [Hash] hash hash given for a signing
      def fill_required_signature(privkey, hash)
        if target.parent.author == author && parent_author_signature.nil?
          hash[:parent_author_signature] = SignedRetraction.sign_with_key(privkey, self)
        elsif target.author == author && target_author_signature.nil?
          hash[:target_author_signature] = SignedRetraction.sign_with_key(privkey, self)
        end
      end
    end
  end
end
