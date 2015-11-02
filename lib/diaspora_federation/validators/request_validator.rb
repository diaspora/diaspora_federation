module DiasporaFederation
  module Validators
    class RequestValidator < Validation::Validator
      include Validation

      rule :sender_id, %i(not_empty diaspora_id)
      rule :recipient_id, %i(not_empty diaspora_id)
    end
  end
end
