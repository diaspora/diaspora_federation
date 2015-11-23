module DiasporaFederation
  module Validators
    # This validates a {Entities::Reshare}
    class ReshareValidator < Validation::Validator
      include Validation

      rule :root_diaspora_id, %i(not_empty diaspora_id)

      rule :root_guid, :guid

      rule :guid, :guid

      rule :diaspora_id, %i(not_empty diaspora_id)

      rule :public, :boolean
    end
  end
end
