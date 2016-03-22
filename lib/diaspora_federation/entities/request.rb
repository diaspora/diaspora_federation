module DiasporaFederation
  module Entities
    # this entity represents a sharing request for a user. A user issues it
    # when he starts sharing with another user.
    #
    # @see Validators::RequestValidator
    # @deprecated will be replaced with {Contact}
    class Request < Entity
      # @!attribute [r] author
      #   The diaspora ID of the person who shares his profile
      #   @see Person#author
      #   @return [String] sender ID
      property :author, xml_name: :sender_handle

      # @!attribute [r] recipient
      #   The diaspora ID of the person who will be shared with
      #   @see Validation::Rule::DiasporaId
      #   @return [String] recipient ID
      property :recipient, xml_name: :recipient_handle

      # use only {Contact} for receive
      # @return [Contact] instance as contact
      def to_contact
        Contact.new(author: author, recipient: recipient)
      end

      # @param [Nokogiri::XML::Element] root_node xml nodes
      # @return [Retraction] instance
      def self.populate_entity(root_node)
        super(root_node).to_contact
      end
      private_class_method :populate_entity
    end
  end
end
