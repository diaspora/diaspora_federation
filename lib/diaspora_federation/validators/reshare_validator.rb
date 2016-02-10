module DiasporaFederation
  module Validators
    # This validates a {Entities::Reshare}
    class ReshareValidator < Validation::Validator
      include Validation

      rule :root_author, %i(not_empty diaspora_id)

      rule :root_guid, :guid

      rule :author, %i(not_empty diaspora_id)

      rule :guid, :guid

      rule :public, :boolean
    end
  end
end
