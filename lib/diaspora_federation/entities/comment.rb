module DiasporaFederation
  module Entities
    # this entity represents a comment to some kind of post (e.g. status message)
    #
    # @see Validators::CommentValidator
    class Comment < Entity
      # @!attribute [r] guid
      #   @see HCard#guid
      #   @return [String] guid
      property :guid

      include Relayable

      # @!attribute [r] text
      #   @return [String] the comment text
      property :text

      # @!attribute [r] diaspora_id
      #   The diaspora ID of the person
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      property :diaspora_id, xml_name: :diaspora_handle
    end
  end
end
