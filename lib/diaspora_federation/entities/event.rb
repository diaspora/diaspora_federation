module DiasporaFederation
  module Entities
    # This entity represents an event and it is federated as a part of a status message.
    #
    # @see Validators::EventValidator
    class Event < Entity
      # @!attribute [r] author
      #   The diaspora* ID of the person who created the event
      #   @see Person#author
      #   @return [String] author diaspora* ID
      property :author, :string

      # @!attribute [r] guid
      #   A random string of at least 16 chars
      #   @see Validation::Rule::Guid
      #   @return [String] guid
      property :guid, :string

      # @!attribute [r] summary
      #   The summary of the event
      #   @return [String] event summary
      property :summary, :string

      # @!attribute [r] description
      #   Description of the event
      #   @return [String] event description
      property :description, :string, default: nil

      # @!attribute [r] start
      #   The start time of the event
      #   @return [String] event start
      property :start, :timestamp

      # @!attribute [r] end
      #   The end time of the event
      #   @return [String] event end
      property :end, :timestamp, default: nil

      # @!attribute [r] all_day
      #   Points if the event is an all day event
      #   @return [Boolean] is it an all day event
      property :all_day, :boolean, default: false

      # @!attribute [r] timezone
      #   Timezone to which the event is fixed to
      #   @return [String] timezone
      property :timezone, :string, default: nil

      # @!attribute [r] location
      #   Location of the event
      #   @return [Entities::Location] location
      entity :location, Entities::Location, default: nil
    end
  end
end
