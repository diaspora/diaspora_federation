module DiasporaFederation
  module Validators
    class LikeValidator < Validation::Validator
      include Validation

      rule :guid, :guid

      include RelayableValidator

      rule :diaspora_id, %i(not_empty diaspora_id)
    end
  end
end
