# frozen_string_literal: true

module DiasporaFederation
  module Entities
    # This entity represents a comment to some kind of post (e.g. status message).
    #
    # @see Validators::CommentValidator
    class Comment < Entity
      # The {Comment} parent is a {Post}
      PARENT_TYPE = "Post"

      include Relayable

      # @!attribute [r] text
      #   @return [String] the comment text
      property :text, :string

      # @!attribute [r] created_at
      #   Comment entity creation time
      #   @return [Time] creation time
      property :created_at, :timestamp, default: -> { Time.now.utc }

      # @!attribute [r] edited_at
      #   The timestamp when the comment was edited
      #   @return [Time] edited time
      property :edited_at, :timestamp, optional: true

      # @!attribute [r] guid
      #   A random string of at least 16 chars pointing to a parent comment.
      #   @see Validation::Rule::Guid
      #   @return [String] parent comment guid
      property :thread_parent_guid, :string, optional: true
    end
  end
end
