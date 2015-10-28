module DiasporaFederation
  module Validators
    class RequestValidator < Validation::Validator
      include Validation

      rule :sender_id, %i(not_nil diaspora_id)
      rule :recipient_id, %i(not_nil diaspora_id)
    end
  end
end
