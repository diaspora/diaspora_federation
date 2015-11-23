module DiasporaFederation
  module Entities
    # this entity represents the fact the a user reshared some other user's post
    #
    # @see Validators::ReshareValidator
    class Reshare < Entity
      # @!attribute [r] diaspora_id
      #   The diaspora ID of the person who posted the original post
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      property :root_diaspora_id # inconsistent, everywhere else it's "handle"

      # @!attribute [r] root_guid
      #   guid of the original post
      #   @see HCard#guid
      #   @return [String] root guid
      property :root_guid

      # @!attribute [r] guid
      #   @see HCard#guid
      #   @return [String] guid
      property :guid

      # @!attribute [r] diaspora_id
      #   The diaspora ID of the person who reshares a post
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      property :diaspora_id, xml_name: :diaspora_handle

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
      #   @return [String] provider display name
      property :provider_display_name, default: nil
    end
  end
end
