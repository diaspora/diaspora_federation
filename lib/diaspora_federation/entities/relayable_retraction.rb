module DiasporaFederation
  module Entities
    # this entity represents a claim of deletion of a previously federated
    # relayable entity ({Entities::Comment}, {Entities::Like})
    #
    # There are two cases of federation of the RelayableRetraction.
    # Retraction from the dowstream object owner is when an author of the
    # relayable (e.g. Comment) deletes it himself. In this case only target_author_signature
    # is filled and retraction is sent to the commented post's author. Here
    # he (upstream object owner) signes it with parent's author key and fills
    # signature in parent_author_signature and sends it to other pods where
    # other participating people present. This is the second case - retraction
    # from the upstream object owner.
    # Retraction from the upstream object owner can also be performed by the
    # upstream object owner himself - he has a right to delete comments on his posts.
    # In any case in the retraction by the upstream author target_author_signature
    # is not checked, only parent_author_signature is checked.
    #
    # @see Validators::RelayableRetractionValidator
    # @deprecated will be replaced with {Entities::Retraction}
    class RelayableRetraction < Entity
      # @!attribute [r] parent_author_signature
      #   Contains a signature of the entity using the private key of the author of a parent post
      #   This signature is mandatory only when federation from an upstream author to the subscribers.
      #   @see Relayable#parent_author_signature
      #   @return [String] parent author signature
      property :parent_author_signature, default: nil

      # @!attribute [r] target_guid
      #   guid of a relayable to be deleted
      #   @see Comment#guid
      #   @return [String] target guid
      property :target_guid

      # @!attribute [r] target_type
      #   a string describing a type of the target
      #   @see Retraction#target_type
      #   @return [String] target type
      property :target_type

      # @!attribute [r] diaspora_id
      #   The diaspora ID of the person who deletes a relayable
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      property :diaspora_id, xml_name: :sender_handle

      # @!attribute [r] target_author_signature
      #   Contains a signature of the entity using the private key of the
      #   author of a federated relayable entity ({Entities::Comment}, {Entities::Like})
      #   This signature is mandatory only when federation from the subscriber to an upstream
      #   author is done.
      #   @see Relayable#author_signature
      #   @return [String] target author signature
      property :target_author_signature, default: nil

      # Generates XML and updates signatures
      # @see Entity#to_xml
      # @return [Nokogiri::XML::Element] root element containing properties as child elements
      def to_xml
        entity_xml.tap do |xml|
          hash = to_h
          RelayableRetraction.update_signatures!(hash)
          xml.at_xpath("target_author_signature").content = hash[:target_author_signature]
          xml.at_xpath("parent_author_signature").content = hash[:parent_author_signature]
        end
      end

      # Adds signatures to a given hash with the keys of the author and the parent
      # if the signatures are not in the hash yet and if the keys are available.
      #
      # @param [Hash] hash hash given for a signing
      def self.update_signatures!(hash)
        target_author = DiasporaFederation.callbacks.trigger(
          :fetch_entity_author_id_by_guid,
          hash[:target_type],
          hash[:target_guid]
        )
        privkey = DiasporaFederation.callbacks.trigger(:fetch_private_key_by_diaspora_id, hash[:diaspora_id])

        fill_required_signature(target_author, privkey, hash) unless privkey.nil?
      end

      # @param [String] target_author the author of the entity to retract
      # @param [OpenSSL::PKey::RSA] privkey private key of sender
      # @param [Hash] hash hash given for a signing
      def self.fill_required_signature(target_author, privkey, hash)
        if target_author == hash[:diaspora_id] && hash[:target_author_signature].nil?
          hash[:target_author_signature] =
            Signing.sign_with_key(SignedRetraction.apply_signable_exceptions(hash), privkey)
        elsif target_author != hash[:diaspora_id] && hash[:parent_author_signature].nil?
          hash[:parent_author_signature] =
            Signing.sign_with_key(SignedRetraction.apply_signable_exceptions(hash), privkey)
        end
      end
      private_class_method :fill_required_signature
    end
  end
end
