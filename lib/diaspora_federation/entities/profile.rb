module DiasporaFederation
  module Entities
    # This entity contains all the profile data of a person.
    #
    # @see Validators::ProfileValidator
    class Profile < Entity
      # @!attribute [r] author
      #   The diaspora* ID of the person
      #   @see Person#author
      #   @return [String] diaspora* ID
      # @!attribute [r] diaspora_id
      #   Alias for author
      #   @see Profile#author
      #   @return [String] diaspora* ID
      property :author, :string, alias: :diaspora_id, xml_name: :diaspora_handle

      # @!attribute [r] first_name
      #   @deprecated We decided to only use one name field, these should be removed
      #     in later iterations (will affect older diaspora* installations).
      #   @see #full_name
      #   @see Discovery::HCard#first_name
      #   @return [String] first name
      property :first_name, :string, default: nil

      # @!attribute [r] last_name
      #   @deprecated We decided to only use one name field, these should be removed
      #     in later iterations (will affect older diaspora* installations).
      #   @see #full_name
      #   @see Discovery::HCard#last_name
      #   @return [String] last name
      property :last_name, :string, default: nil

      # @!attribute [r] image_url
      #   @see Discovery::HCard#photo_large_url
      #   @return [String] url to the big avatar (300x300)
      property :image_url, :string, default: nil
      # @!attribute [r] image_url_medium
      #   @see Discovery::HCard#photo_medium_url
      #   @return [String] url to the medium avatar (100x100)
      property :image_url_medium, :string, default: nil
      # @!attribute [r] image_url_small
      #   @see Discovery::HCard#photo_small_url
      #   @return [String] url to the small avatar (50x50)
      property :image_url_small, :string, default: nil

      property :birthday, :string, default: nil
      property :gender, :string, default: nil
      property :bio, :string, default: nil
      property :location, :string, default: nil

      # @!attribute [r] searchable
      #   @see Discovery::HCard#searchable
      #   @return [Boolean] searchable flag
      property :searchable, :boolean, default: true

      property :nsfw, :boolean, default: false
      property :tag_string, :string, default: nil

      # @return [String] string representation of this object
      def to_s
        "Profile:#{author}"
      end
    end
  end
end
