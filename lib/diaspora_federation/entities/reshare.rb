module DiasporaFederation
  module Entities
    # this entity represents the fact the a user reshared some other user's post
    #
    # @see Validators::ReshareValidator
    class Reshare < Entity
      include Post

      # @!attribute [r] root_author
      #   The diaspora ID of the person who posted the original post
      #   @see Person#author
      #   @return [String] diaspora ID
      property :root_author, xml_name: :root_diaspora_id

      # @!attribute [r] root_guid
      #   guid of the original post
      #   @see StatusMessage#guid
      #   @return [String] root guid
      property :root_guid

      # @!attribute [r] public
      #   has no meaning at the moment
      #   @return [Boolean] public
      property :public, default: true # always true? (we only reshare public posts)
    end
  end
end
