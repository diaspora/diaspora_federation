module DiasporaFederation
  module Entities
    # this entity contains all the profile data of a person
    class Profile < Entity
      # @!attribute [r] diaspora_handle
      #   The diaspora handle of the person
      #   @see Person#diaspora_handle
      #   @return [String] diaspora handle
      property :diaspora_handle

      # @!attribute [r] first_name
      #   @deprecated
      #   @see #full_name
      #   @see HCard#first_name
      #   @return [String] first name
      property :first_name, default: nil

      # @!attribute [r] last_name
      #   @deprecated
      #   @see #full_name
      #   @see HCard#last_name
      #   @return [String] last name
      property :last_name, default: nil
      # @!attribute [r] image_url
      #   @see HCard#photo_large_url
      #   @return [String] url to the big avatar (300x300)
      property :image_url, default: nil
      # @!attribute [r] image_url_medium
      #   @see HCard#photo_medium_url
      #   @return [String] url to the medium avatar (100x100)
      property :image_url_medium, default: nil
      # @!attribute [r] image_url_small
      #   @see HCard#photo_small_url
      #   @return [String] url to the small avatar (50x50)
      property :image_url_small, default: nil

      property :birthday, default: nil
      property :gender, default: nil
      property :bio, default: nil
      property :location, default: nil

      # @!attribute [r] searchable
      #   @see HCard#searchable
      #   @return [Boolean] searchable flag
      property :searchable, default: true

      property :nsfw, default: false
      property :tag_string, default: nil
    end
  end
end
