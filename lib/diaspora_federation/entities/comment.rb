module DiasporaFederation
  module Entities
    # this entity represents a comment to some kind of post (e.g. status message)
    #
    # @see Validators::CommentValidator
    class Comment < Entity
      # old signature order
      # @deprecated
      LEGACY_SIGNATURE_ORDER = %i(guid parent_guid text author).freeze

      include Relayable

      # @!attribute [r] text
      #   @return [String] the comment text
      property :text

      # @!attribute [r] created_at
      #   comment entity creation time
      #   @return [Time] creation time
      property :created_at, default: -> { Time.now.utc }

      # The {Comment} parent is a Post
      # @return [String] parent type
      def parent_type
        "Post"
      end
    end
  end
end
