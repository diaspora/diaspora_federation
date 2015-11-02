module DiasporaFederation
  module Validators
    class LocationValidator < Validation::Validator
      include Validation

      rule :lat, :not_empty
      rule :lng, :not_empty
    end
  end
end
