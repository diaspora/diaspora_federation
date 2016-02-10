module DiasporaFederation
  module Entities
    # this entity represents the fact the a user reshared some other user's post
    #
    # @see Validators::ReshareValidator
    class Reshare < Entity
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

      # @!attribute [r] author
      #   The diaspora ID of the person who reshares a post
      #   @see Person#author
      #   @return [String] diaspora ID
      property :author, xml_name: :diaspora_handle

      # @!attribute [r] guid
      #   a random string of at least 16 chars.
      #   @see Validation::Rule::Guid
      #   @see StatusMessage#guid
      #   @return [String] guid
      property :guid

      # @!attribute [r] public
      #   has no meaning at the moment
      #   @return [Boolean] public
      property :public, default: true # always true? (we only reshare public posts)

      # @!attribute [r] created_at
      #   reshare entity creation time
      #   @return [Time] creation time
      property :created_at, default: -> { Time.now.utc }

      # @!attribute [r] provider_display_name
      #   a string that describes a means by which a user has posted the reshare
      #   @see StatusMessage#provider_display_name
      #   @return [String] provider display name
      property :provider_display_name, default: nil
    end
  end
end
