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

      # target entity
      # @return [RelatedEntity] target entity
      attr_reader :target

      # Initializes a new signed retraction entity
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

      private

      # @param [Nokogiri::XML::Element] root_node xml nodes
      # @return [Retraction] instance
      def self.populate_entity(root_node)
        entity_data = entity_data(root_node)
        entity_data[:target] = Retraction.send(:fetch_target, entity_data[:target_type], entity_data[:target_guid])
        new(entity_data).to_retraction
      end
      private_class_method :populate_entity

      # It updates also the signatures with the keys of the author and the parent
      # if the signatures are not there yet and if the keys are available.
      #
      # @return [Hash] xml elements with updated signatures
      def xml_elements
        super.tap do |xml_elements|
          xml_elements[:target_author_signature] = target_author_signature || sign_with_author.to_s
        end
      end

      def sign_with_author
        privkey = DiasporaFederation.callbacks.trigger(:fetch_private_key, author)
        SignedRetraction.sign_with_key(privkey, self) unless privkey.nil?
      end
    end
  end
end
