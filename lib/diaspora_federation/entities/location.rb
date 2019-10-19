# frozen_string_literal: true

module DiasporaFederation
  module Entities
    # This entity is used to specify location data and used embedded in a status message.
    #
    # @see Validators::LocationValidator
    class Location < Entity
      # @!attribute [r] address
      #   A string describing your location, e.g. a city name, a street name, etc
      #   @return [String] address
      property :address, :string

      # @!attribute [r] lat
      #   Geographical latitude of your location
      #   @return [String] latitude
      property :lat, :string

      # @!attribute [r] lng
      #   Geographical longitude of your location
      #   @return [String] longitude
      property :lng, :string
    end
  end
end
