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

      def initialize(*)
        raise "Sending Request is not supported anymore! Use Contact instead!"
      end

      # @return [Retraction] instance
      def self.from_hash(hash)
        Contact.new(hash)
      end
    end
  end
end
