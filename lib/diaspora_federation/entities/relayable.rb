module DiasporaFederation
  module Entities
    # This is a module that defines common properties for relayable entities
    # which include Like, Comment, Participation, Message, etc. Each relayable
    # has a parent, identified by guid. Relayables are also signed and signing/verification
    # logic is embedded into Salmon XML processing code.
    module Relayable
      include Logging

      # Digest instance used for signing
      DIGEST = OpenSSL::Digest::SHA256.new

      # Order from the parsed xml for signature
      # @return [Array] order from xml
      attr_reader :xml_order

      # Additional properties from parsed xml
      # @return [Hash] additional xml elements
      attr_reader :additional_xml_elements

      # On inclusion of this module the required properties for a relayable are added to the object that includes it.
      #
      # @!attribute [r] author
      #   The diaspora* ID of the author
      #   @see Person#author
      #   @return [String] diaspora* ID
      #
      # @!attribute [r] guid
      #   A random string of at least 16 chars
      #   @see Validation::Rule::Guid
      #   @return [String] comment guid
      #
      # @!attribute [r] parent_guid
      #   @see StatusMessage#guid
      #   @return [String] parent guid
      #
      # @!attribute [r] author_signature
      #   Contains a signature of the entity using the private key of the author of a post itself
      #   The presence of this signature is mandatory. Without it the entity won't be accepted by
      #   a target pod.
      #   @return [String] author signature
      #
      # @!attribute [r] parent_author_signature
      #   Contains a signature of the entity using the private key of the author of a parent post
      #   This signature is required only when federating from upstream (parent) post author to
      #   downstream subscribers. This is the case when the parent author has to resend a relayable
      #   received from one of their subscribers to all others.
      #   @return [String] parent author signature
      #
      # @!attribute [r] parent
      #   Meta information about the parent object
      #   @return [RelatedEntity] parent entity
      #
      # @param [Entity] klass the entity in which it is included
      def self.included(klass)
        klass.class_eval do
          property :author, xml_name: :diaspora_handle
          property :guid
          property :parent_guid
          property :author_signature, default: nil
          property :parent_author_signature, default: nil
          entity :parent, Entities::RelatedEntity
        end

        klass.extend ParseXML
      end

      # Initializes a new relayable Entity with order and additional xml elements
      #
      # @param [Hash] data entity data
      # @param [Array] xml_order order from xml
      # @param [Hash] additional_xml_elements additional xml elements
      # @see DiasporaFederation::Entity#initialize
      def initialize(data, xml_order=nil, additional_xml_elements={})
        @xml_order = xml_order.try(:reject) {|name| name =~ /signature/ }
        @additional_xml_elements = additional_xml_elements

        super(data)
      end

      # Verifies the signatures (+author_signature+ and +parent_author_signature+ if needed).
      # @raise [SignatureVerificationFailed] if the signature is not valid or no public key is found
      def verify_signatures
        verify_signature(author, :author_signature)

        # This happens only on downstream federation.
        verify_signature(parent.author, :parent_author_signature) unless parent.local
      end

      def sender_valid?(sender)
        sender == author || sender == parent.author
      end

      # @return [String] string representation of this object
      def to_s
        "#{super}#{":#{parent_type}" if respond_to?(:parent_type)}:#{parent_guid}"
      end

      private

      # Check that signature is a correct signature
      #
      # @param [String] author The author of the signature
      # @param [String] signature_key The signature to be verified
      # @return [Boolean] signature valid
      def verify_signature(author, signature_key)
        pubkey = DiasporaFederation.callbacks.trigger(:fetch_public_key, author)
        raise PublicKeyNotFound, "signature=#{signature_key} person=#{author} obj=#{self}" if pubkey.nil?

        signature = public_send(signature_key)
        raise SignatureVerificationFailed, "no #{signature_key} for #{self}" if signature.nil?

        valid = pubkey.verify(DIGEST, Base64.decode64(signature), signature_data)
        raise SignatureVerificationFailed, "wrong #{signature_key} for #{self}" unless valid

        logger.info "event=verify_signature signature=#{signature_key} status=valid obj=#{self}"
      end

      # Sign with author key
      # @raise [AuthorPrivateKeyNotFound] if the author private key is not found
      # @return [String] A Base64 encoded signature of #signature_data with key
      def sign_with_author
        privkey = DiasporaFederation.callbacks.trigger(:fetch_private_key, author)
        raise AuthorPrivateKeyNotFound, "author=#{author} obj=#{self}" if privkey.nil?
        sign_with_key(privkey).tap do
          logger.info "event=sign status=complete signature=author_signature author=#{author} obj=#{self}"
        end
      end

      # Sign with parent author key, if the parent author is local (if the private key is found)
      # @return [String] A Base64 encoded signature of #signature_data with key
      def sign_with_parent_author_if_available
        privkey = DiasporaFederation.callbacks.trigger(:fetch_private_key, parent.author)
        if privkey
          sign_with_key(privkey).tap do
            logger.info "event=sign status=complete signature=parent_author_signature obj=#{self}"
          end
        end
      end

      # Sign the data with the key
      #
      # @param [OpenSSL::PKey::RSA] privkey An RSA key
      # @return [String] A Base64 encoded signature of #signature_data with key
      def sign_with_key(privkey)
        Base64.strict_encode64(privkey.sign(DIGEST, signature_data))
      end

      # Sort all XML elements according to the order used for the signatures.
      # It updates also the signatures with the keys of the author and the parent
      # if the signatures are not there yet and if the keys are available.
      #
      # @return [Hash] sorted xml elements with updated signatures
      def xml_elements
        xml_data = super.merge(additional_xml_elements)
        signature_order.map {|element| [element, xml_data[element] || ""] }.to_h.tap do |xml_elements|
          xml_elements[:author_signature] = author_signature || sign_with_author
          xml_elements[:parent_author_signature] = parent_author_signature || sign_with_parent_author_if_available.to_s
        end
      end

      # The order for signing
      # @return [Array]
      def signature_order
        if xml_order
          prop_names = self.class.class_props.keys.map(&:to_s)
          xml_order.map {|name| prop_names.include?(name) ? name.to_sym : name }
        else
          self.class::LEGACY_SIGNATURE_ORDER
        end
      end

      # @return [String] signature data string
      def signature_data
        data = to_h.merge(additional_xml_elements)
        signature_order.map {|name| data[name] }.join(";")
      end

      # Override class methods from {Entity} to parse the xml
      module ParseXML
        private

        # @param [Nokogiri::XML::Element] root_node xml nodes
        # @return [Entity] instance
        def populate_entity(root_node)
          # Use all known properties to build the Entity (entity_data). All additional xml elements
          # are respected and attached to a hash as string (additional_xml_elements). It also remembers
          # the order of the xml-nodes (xml_order). This is needed to support receiving objects from
          # the future versions of diaspora*, where new elements may have been added.
          entity_data = {}
          additional_xml_elements = {}

          xml_order = root_node.element_children.map do |child|
            xml_name = child.name
            property = find_property_for_xml_name(xml_name)

            if property
              entity_data[property] = parse_element_from_node(xml_name, class_props[property], root_node)
              property
            else
              additional_xml_elements[xml_name] = child.text
              xml_name
            end
          end

          fetch_parent(entity_data)
          new(entity_data, xml_order, additional_xml_elements).tap(&:verify_signatures)
        end

        def fetch_parent(data)
          type = data.fetch(:parent_type) {
            if const_defined?(:PARENT_TYPE)
              self::PARENT_TYPE
            else
              raise DiasporaFederation::Entity::ValidationError, "invalid #{self}! missing 'parent_type'."
            end
          }
          guid = data.fetch(:parent_guid) {
            raise DiasporaFederation::Entity::ValidationError, "invalid #{self}! missing 'parent_guid'."
          }

          data[:parent] = DiasporaFederation.callbacks.trigger(:fetch_related_entity, type, guid)

          unless data[:parent]
            # Fetch and receive parent from remote, if not available locally
            Federation::Fetcher.fetch_public(data[:author], type, guid)
            data[:parent] = DiasporaFederation.callbacks.trigger(:fetch_related_entity, type, guid)
          end
        end
      end

      # Raised, if creating the author_signature fails, because the private key was not found
      class AuthorPrivateKeyNotFound < RuntimeError
      end

      # Raised, if verify_signatures fails to verify signatures (no public key found)
      class PublicKeyNotFound < RuntimeError
      end

      # Raised, if verify_signatures fails to verify signatures (signatures are wrong)
      class SignatureVerificationFailed < RuntimeError
      end
    end
  end
end
