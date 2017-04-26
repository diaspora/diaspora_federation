module DiasporaFederation
  module Entities
    # This entity represents a comment to some kind of post (e.g. status message).
    #
    # @see Validators::CommentValidator
    class Comment < Entity
      # The {Comment} parent is a {Post}
      PARENT_TYPE = "Post".freeze

      include Relayable

      # @!attribute [r] text
      #   @return [String] the comment text
      property :text, :string

      # @!attribute [r] created_at
      #   Comment entity creation time
      #   @return [Time] creation time
      property :created_at, :timestamp, default: -> { Time.now.utc }

      private

      # Remove "created_at" when no order was received.
      # @deprecated TODO: Remove this, this will break compatibility with pods older than 0.6.3.0.
      def signature_order
        super.tap {|order| order.delete(:created_at) unless xml_order }
      end
    end
  end
end
