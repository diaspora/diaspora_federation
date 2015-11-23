module DiasporaFederation
  module Validators
    # This validates a {Entities::Like}
    class LikeValidator < Validation::Validator
      include Validation

      rule :guid, :guid

      include RelayableValidator

      rule :diaspora_id, %i(not_empty diaspora_id)
    end
  end
end
