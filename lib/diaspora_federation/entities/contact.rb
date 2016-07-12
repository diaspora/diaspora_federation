module DiasporaFederation
  module Entities
    # This entity represents a contact with another person. A user issues it
    # when they start sharing/following with another user.
    #
    # @see Validators::ContactValidator
    class Contact < Entity
      # @!attribute [r] author
      #   The diaspora* ID of the person who shares their profile
      #   @see Person#author
      #   @return [String] sender ID
      property :author

      # @!attribute [r] recipient
      #   The diaspora* ID of the person who will be shared with
      #   @see Validation::Rule::DiasporaId
      #   @return [String] recipient ID
      property :recipient

      # @!attribute [r] following
      #   @return [Boolean] if the author is following the person
      property :following, default: true

      # @!attribute [r] sharing
      #   @return [Boolean] if the author is sharing with the person
      property :sharing, default: true

      # @return [String] string representation of this object
      def to_s
        "Contact:#{author}:#{recipient}"
      end
    end
  end
end
