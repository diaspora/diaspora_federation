module DiasporaFederation
  module Entities
    # this entity is used to specify a location data and used embedded in a status message
    #
    # @see Validators::LocationValidator
    class Location < Entity
      # @!attribute [r] address
      #   A string describing your location, e.g. a city name, a street name, etc
      #   @return [String] address
      property :address

      # @!attribute [r] lat
      #   Geographical latitude of your location
      #   @return [String] latitude
      property :lat

      # @!attribute [r] lng
      #   Geographical longitude of your location
      #   @return [String] longitude
      property :lng
    end
  end
end
