module DiasporaFederation
  module Entities
    # This entity represents a status message sent by a user.
    #
    # @see Validators::StatusMessageValidator
    class StatusMessage < Entity
      include Post

      # @!attribute [r] text
      #   Text of the status message composed by the user
      #   @return [String] text of the status message
      property :text, :string, xml_name: :raw_message

      # @!attribute [r] edited_at
      #   The timestamp when the status message was edited
      #   @return [Time] edited time
      property :edited_at, :timestamp, optional: true

      # @!attribute [r] photos
      #   Optional photos attached to the status message
      #   @return [[Entities::Photo]] photos
      entity :photos, [Entities::Photo], optional: true, default: []

      # @!attribute [r] location
      #   Optional location attached to the status message
      #   @return [Entities::Location] location
      entity :location, Entities::Location, optional: true

      # @!attribute [r] poll
      #   Optional poll attached to the status message
      #   @return [Entities::Poll] poll
      entity :poll, Entities::Poll, optional: true

      # @!attribute [r] event
      #   Optional event attached to the status message
      #   @return [Entities::Event] event
      entity :event, Entities::Event, optional: true

      # @!attribute [r] embed
      #   Optional embed information of an URL that should be embedded in the status message
      #   @return [Entities::Embed] embed
      entity :embed, Entities::Embed, optional: true

      private

      def validate
        super
        photos.each do |photo|
          if photo.author != author
            raise ValidationError, "nested #{photo} has different author: author=#{author} obj=#{self}"
          end
        end
      end
    end
  end
end
