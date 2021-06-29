# frozen_string_literal: true

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
      property :author, :string, alias: :diaspora_id

      # @!attribute [r] edited_at
      #   The timestamp when the profile was edited
      #   @return [Time] edited time
      property :edited_at, :timestamp, optional: true

      # @!attribute [r] full_name
      #   @return [String] display name of the user
      property :full_name, :string, optional: true

      # @!attribute [r] first_name
      #   @deprecated We decided to only use one name field, these should be removed
      #     in later iterations (will affect older diaspora* installations).
      #   @see #full_name
      #   @see Discovery::HCard#first_name
      #   @return [String] first name
      property :first_name, :string, optional: true

      # @!attribute [r] last_name
      #   @deprecated We decided to only use one name field, these should be removed
      #     in later iterations (will affect older diaspora* installations).
      #   @see #full_name
      #   @see Discovery::HCard#last_name
      #   @return [String] last name
      property :last_name, :string, optional: true

      # @!attribute [r] image_url
      #   @see Discovery::HCard#photo_large_url
      #   @return [String] url to the big avatar (300x300)
      property :image_url, :string, optional: true
      # @!attribute [r] image_url_medium
      #   @see Discovery::HCard#photo_medium_url
      #   @return [String] url to the medium avatar (100x100)
      property :image_url_medium, :string, optional: true
      # @!attribute [r] image_url_small
      #   @see Discovery::HCard#photo_small_url
      #   @return [String] url to the small avatar (50x50)
      property :image_url_small, :string, optional: true

      # @!attribute [r] bio
      #   @return [String] bio of the person
      property :bio, :string, alias: :text, optional: true

      property :birthday, :string, optional: true
      property :gender, :string, optional: true
      property :location, :string, optional: true

      # @!attribute [r] searchable
      #   @see Discovery::HCard#searchable
      #   @return [Boolean] searchable flag
      property :searchable, :boolean, optional: true, default: true

      # @!attribute [r] public
      #   Shows whether the profile is visible to everyone or only to contacts
      #   @return [Boolean] is it public
      property :public, :boolean, optional: true, default: false

      property :nsfw, :boolean, optional: true, default: false
      property :tag_string, :string, optional: true

      # @return [String] string representation of this object
      def to_s
        "Profile:#{author}"
      end
    end
  end
end
