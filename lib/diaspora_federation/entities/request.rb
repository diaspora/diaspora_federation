module DiasporaFederation
  module Entities
    # this entity represents a sharing request for a user. A user issues it
    # when she wants to share her private posts with the recipient.
    #
    # @see Validators::RequestValidator
    class Request < Entity
      # @!attribute [r] sender_id
      #   The diaspora ID of the person who shares his private posts
      #   @see Person#diaspora_id
      #   @return [String] sender ID
      property :sender_id, xml_name: :sender_handle

      # @!attribute [r] recipient_id
      #   The diaspora ID of the person who will be shared with
      #   @see Person#diaspora_id
      #   @return [String] recipient ID
      property :recipient_id, xml_name: :recipient_handle
    end
  end
end
