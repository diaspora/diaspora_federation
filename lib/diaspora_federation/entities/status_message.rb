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

      # @!attribute [r] photos
      #   Optional photos attached to the status message
      #   @return [[Entities::Photo]] photos
      entity :photos, [Entities::Photo], default: []

      # @!attribute [r] location
      #   Optional location attached to the status message
      #   @return [Entities::Location] location
      entity :location, Entities::Location, default: nil

      # @!attribute [r] poll
      #   Optional poll attached to the status message
      #   @return [Entities::Poll] poll
      entity :poll, Entities::Poll, default: nil

      # @!attribute [r] event
      #   Optional event attached to the status message
      #   @return [Entities::Event] event
      entity :event, Entities::Event, default: nil

      # @!attribute [r] public
      #   Shows whether the status message is visible to everyone or only to some aspects
      #   @return [Boolean] is it public
      property :public, :boolean, default: false

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
