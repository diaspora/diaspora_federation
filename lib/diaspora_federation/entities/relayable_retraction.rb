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

      # @!attribute [r] author
      #   The diaspora ID of the person who deletes a relayable
      #   @see Person#author
      #   @return [String] diaspora ID
      property :author, xml_name: :sender_handle

      # @!attribute [r] target_author_signature
      #   Contains a signature of the entity using the private key of the
      #   author of a federated relayable entity ({Entities::Comment}, {Entities::Like})
      #   This signature is mandatory only when federation from the subscriber to an upstream
      #   author is done.
      #   @see Relayable#author_signature
      #   @return [String] target author signature
      property :target_author_signature, default: nil

      # target entity
      # @return [RelatedEntity] target entity
      attr_reader :target

      # Initializes a new relayable retraction entity
      #
      # @param [Hash] data entity data
      # @see DiasporaFederation::Entity#initialize
      def initialize(data)
        @target = data[:target] if data
        super(data)
      end

      # use only {Retraction} for receive
      # @return [Retraction] instance as normal retraction
      def to_retraction
        Retraction.new(author: author, target_guid: target_guid, target_type: target_type)
      end

      private

      # @param [Nokogiri::XML::Element] root_node xml nodes
      # @return [Retraction] instance
      def self.populate_entity(root_node)
        entity_data = Hash[class_props.map {|name, type|
          [name, parse_element_from_node(name, type, root_node)]
        }]

        entity_data[:target] = fetch_target(entity_data[:target_type], entity_data[:target_guid])
        new(entity_data).to_retraction
      end
      private_class_method :populate_entity

      def self.fetch_target(target_type, target_guid)
        DiasporaFederation.callbacks.trigger(:fetch_related_entity, target_type, target_guid).tap do |target|
          raise TargetNotFound unless target
        end
      end
      private_class_method :fetch_target

      # It updates also the signatures with the keys of the author and the parent
      # if the signatures are not there yet and if the keys are available.
      #
      # @return [Hash] xml elements with updated signatures
      def xml_elements
        privkey = DiasporaFederation.callbacks.trigger(:fetch_private_key_by_diaspora_id, author)

        super.tap do |xml_elements|
          fill_required_signature(privkey, xml_elements) unless privkey.nil?
        end
      end

      # @param [OpenSSL::PKey::RSA] privkey private key of sender
      # @param [Hash] hash hash given for a signing
      def fill_required_signature(privkey, hash)
        if target.author == author && target_author_signature.nil?
          hash[:target_author_signature] = SignedRetraction.sign_with_key(privkey, self)
        elsif target.parent.author == author && parent_author_signature.nil?
          hash[:parent_author_signature] = SignedRetraction.sign_with_key(privkey, self)
        end
      end

      # Raised, if the target of the {Retraction} was not found.
      class TargetNotFound < RuntimeError
      end
    end
  end
end
