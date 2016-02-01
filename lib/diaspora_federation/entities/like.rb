module DiasporaFederation
  module Entities
    # this entity represents a like to some kind of post (e.g. status message)
    #
    # @see Validators::LikeValidator
    class Like < Entity
      # old signature order
      # @deprecated
      LEGACY_SIGNATURE_ORDER = %i(positive guid parent_type parent_guid diaspora_id).freeze

      # @!attribute [r] positive
      #   If +true+ set a like, if +false+, set a dislike (dislikes are currently not
      #   implemented in the Diaspora frontend).
      #   @return [Boolean] is it a like or a dislike
      property :positive

      # @!attribute [r] guid
      #   a random string of at least 16 chars.
      #   @see Validation::Rule::Guid
      #   @return [String] like guid
      property :guid

      # @!attribute [r] parent_type
      #   A string describing the type of the parent.
      #   Can be "Post" or "Comment" (Comments are currently not implemented in the
      #   Diaspora Frontend).
      #   @return [String] parent type
      property :parent_type, xml_name: :target_type

      include Relayable

      # @!attribute [r] diaspora_id
      #   The diaspora ID of the person who posts a like
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      property :diaspora_id, xml_name: :diaspora_handle
    end
  end
end
