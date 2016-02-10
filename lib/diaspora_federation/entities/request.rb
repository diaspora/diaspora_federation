module DiasporaFederation
  module Entities
    # this entity represents a sharing request for a user. A user issues it
    # when he starts sharing with another user.
    #
    # @see Validators::RequestValidator
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
    end
  end
end
