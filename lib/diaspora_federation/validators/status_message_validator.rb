module DiasporaFederation
  module Validators
    class StatusMessageValidator < Validation::Validator
      include Validation

      rule :guid, :guid

      rule :diaspora_id, %i(not_empty diaspora_id)

      rule :public, :boolean
    end
  end
end
