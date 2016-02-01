module DiasporaFederation
  module Entities
    # this entity represents a comment to some kind of post (e.g. status message)
    #
    # @see Validators::CommentValidator
    class Comment < Entity
      # old signature order
      # @deprecated
      LEGACY_SIGNATURE_ORDER = %i(guid parent_guid text diaspora_id).freeze

      # @!attribute [r] guid
      #   a random string of at least 16 chars.
      #   @see Validation::Rule::Guid
      #   @return [String] comment guid
      property :guid

      include Relayable

      # @!attribute [r] text
      #   @return [String] the comment text
      property :text

      # @!attribute [r] diaspora_id
      #   The diaspora ID of the author.
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      property :diaspora_id, xml_name: :diaspora_handle

      # The {Comment} parent is a Post
      # @return [String] parent type
      def parent_type
        "Post"
      end
    end
  end
end
