module DiasporaFederation
  module Validators
    # This validates a {Entities::Request}.
    # @deprecated The {Entities::Request} will be replaced with {Entities::Contact}.
    class RequestValidator < Validation::Validator
      include Validation

      rule :author, %i(not_empty diaspora_id)
      rule :recipient, %i(not_empty diaspora_id)
    end
  end
end
