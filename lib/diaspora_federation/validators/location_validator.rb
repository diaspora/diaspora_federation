module DiasporaFederation
  module Validators
    # This validates a {Entities::Location}.
    class LocationValidator < OptionalAwareValidator
      include Validation

      rule :lat, :not_empty
      rule :lng, :not_empty
    end
  end
end
