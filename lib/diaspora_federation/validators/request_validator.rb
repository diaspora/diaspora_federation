module DiasporaFederation
  module Validators
    # This validates a {Entities::Request}
    class RequestValidator < Validation::Validator
      include Validation

      rule :diaspora_id, %i(not_empty diaspora_id)
      rule :recipient_id, %i(not_empty diaspora_id)
    end
  end
end
