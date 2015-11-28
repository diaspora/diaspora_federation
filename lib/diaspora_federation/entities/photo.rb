module DiasporaFederation
  module Entities
    # this entity represents photo and it is federated as a part of a status message
    #
    # @see Validators::PhotoValidator
    class Photo < Entity
      # @!attribute [r] guid
      #   @see HCard#guid
      #   @return [String] guid
      property :guid

      # @!attribute [r] diaspora_id
      #   The diaspora ID of the person who uploaded the photo
      #   @see Person#diaspora_id
      #   @return [String] diaspora ID
      property :diaspora_id, xml_name: :diaspora_handle

      # @!attribute [r] public
      #   Points if the photo is visible to everyone or only to some aspects
      #   @return [Boolean] is it public
      property :public, default: false

      # @!attribute [r] created_at
      #   photo entity creation time
      #   @return [Time] creation time
      property :created_at, default: -> { Time.now.utc }

      # @!attribute [r] remote_photo_path
      #   an url of the photo on a remote server
      #   @return [String] remote photo url
      property :remote_photo_path

      # @!attribute [r] remote_photo_name
      #   @return [String] remote photo name
      property :remote_photo_name

      # @!attribute [r] text
      #   @return [String] text
      property :text, default: nil

      # @!attribute [r] status_message_guid
      #   guid of a status message this message belongs to
      #   @see HCard#guid
      #   @return [String] guid
      property :status_message_guid

      # @!attribute [r] height
      #   photo height
      #   @return [String] height
      property :height

      # @!attribute [r] width
      #   photo width
      #   @return [String] width
      property :width
    end
  end
end
