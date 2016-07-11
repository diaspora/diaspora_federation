module DiasporaFederation
  module Entities
    # This entity represents a comment to some kind of post (e.g. status message).
    #
    # @see Validators::CommentValidator
    class Comment < Entity
      # Old signature order
      # @deprecated
      LEGACY_SIGNATURE_ORDER = %i(guid parent_guid text author).freeze

      # The {Comment} parent is a {Post}
      PARENT_TYPE = "Post".freeze

      include Relayable

      # @!attribute [r] text
      #   @return [String] the comment text
      property :text

      # @!attribute [r] created_at
      #   Comment entity creation time
      #   @return [Time] creation time
      property :created_at, default: -> { Time.now.utc }
    end
  end
end
