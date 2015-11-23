module DiasporaFederation
  module Entities
    # this entity represents a like to some kind of post (e.g. status message)
    #
    # @see Validators::LikeValidator
    class Like < Entity
      # @!attribute [r] positive
      #   If true set a like, if false, set a dislike (dislikes are currently not
      #   implemented in the Diaspora's frontend).
      #   @return [Boolean] is it a like or a dislike
      property :positive

      # @!attribute [r] guid
      #   @see HCard#guid
      #   @return [String] guid
      property :guid

      # @!attribute [r] target_type
      #   a string describing a type of the target
      #   @return [String] target type
      property :target_type

      include Relayable

      # @!attribute [r] diaspora_id
      #   The diaspora ID of the person who posts a like
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      property :diaspora_id, xml_name: :diaspora_handle
    end
  end
end
