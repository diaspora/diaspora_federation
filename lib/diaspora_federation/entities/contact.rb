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
      property :author, :string

      # @!attribute [r] recipient
      #   The diaspora* ID of the person who will be shared with
      #   @see Validation::Rule::DiasporaId
      #   @return [String] recipient ID
      property :recipient, :string

      # @!attribute [r] following
      #   @return [Boolean] if the author is following the person
      property :following, :boolean, default: true

      # @!attribute [r] sharing
      #   @return [Boolean] if the author is sharing with the person
      property :sharing, :boolean, default: true

      # @!attribute [r] blocking
      #   @return [Boolean] if the author is blocking the person
      property :blocking, :boolean, optional: true, default: false

      # @return [String] string representation of this object
      def to_s
        "Contact:#{author}:#{recipient}"
      end

      private

      def validate
        super

        return unless (following || sharing) && blocking

        raise ValidationError,
              "flags invalid: following:#{following}/sharing:#{sharing} and blocking:#{blocking} can't both be true"
      end
    end
  end
end
