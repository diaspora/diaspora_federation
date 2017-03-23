module DiasporaFederation
  module Entities
    # This entity represents a sharing request for a user. A user issues it
    # when they start sharing with another user.
    #
    # @see Validators::RequestValidator
    # @deprecated will be replaced with {Contact}
    class Request < Entity
      # @!attribute [r] author
      #   The diaspora* ID of the person who share their profile
      #   @see Person#author
      #   @return [String] sender ID
      property :author, :string, xml_name: :sender_handle

      # @!attribute [r] recipient
      #   The diaspora* ID of the person who will be shared with
      #   @see Validation::Rule::DiasporaId
      #   @return [String] recipient ID
      property :recipient, :string, xml_name: :recipient_handle

      # Use only {Contact} for receive
      # @return [Contact] instance as contact
      def to_contact
        Contact.new(author: author, recipient: recipient)
      end

      # @return [String] string representation of this object
      def to_s
        "Request:#{author}:#{recipient}"
      end

      # @return [Retraction] instance
      def self.from_hash(hash)
        super.to_contact
      end
    end
  end
end
