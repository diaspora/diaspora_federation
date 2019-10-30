# frozen_string_literal: true

module DiasporaFederation
  module Entities
    # This entity represents a like to some kind of post (e.g. status message).
    #
    # @see Validators::LikeValidator
    class Like < Entity
      include Relayable

      # @!attribute [r] parent_type
      #   A string describing the type of the parent
      #   Can be "Post" or "Comment" (Comments are currently not implemented in the
      #   diaspora* frontend).
      #   @return [String] parent type
      property :parent_type, :string

      # @!attribute [r] positive
      #   If +true+ set a like, if +false+, set a dislike (dislikes are currently not
      #   implemented in the diaspora* frontend).
      #   @return [Boolean] is it a like or a dislike
      property :positive, :boolean
    end
  end
end
