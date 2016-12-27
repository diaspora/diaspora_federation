module DiasporaFederation
  module Entities
    # This entity represents a photo and it is federated as a part of a status message.
    #
    # @see Validators::PhotoValidator
    class Photo < Entity
      # @!attribute [r] guid
      #   A random string of at least 16 chars
      #   @see Validation::Rule::Guid
      #   @return [String] guid
      property :guid, :string

      # @!attribute [r] author
      #   The diaspora* ID of the person who uploaded the photo
      #   @see Person#author
      #   @return [String] author diaspora* ID
      property :author, :string, xml_name: :diaspora_handle

      # @!attribute [r] public
      #   Points if the photo is visible to everyone or only to some aspects
      #   @return [Boolean] is it public
      property :public, :boolean, default: false

      # @!attribute [r] created_at
      #   Photo entity creation time
      #   @return [Time] creation time
      property :created_at, :timestamp, default: -> { Time.now.utc }

      # @!attribute [r] remote_photo_path
      #   An url of the photo on a remote server
      #   @return [String] remote photo url
      property :remote_photo_path, :string

      # @!attribute [r] remote_photo_name
      #   @return [String] remote photo name
      property :remote_photo_name, :string

      # @!attribute [r] text
      #   @return [String] text
      property :text, :string, default: nil

      # @!attribute [r] status_message_guid
      #   Guid of a status message this photo belongs to
      #   @see StatusMessage#guid
      #   @return [String] guid
      property :status_message_guid, :string, default: nil

      # @!attribute [r] height
      #   Photo height
      #   @return [Integer] height
      property :height, :integer

      # @!attribute [r] width
      #   Photo width
      #   @return [Integer] width
      property :width, :integer
    end
  end
end
