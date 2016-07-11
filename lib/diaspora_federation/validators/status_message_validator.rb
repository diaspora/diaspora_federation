module DiasporaFederation
  module Validators
    # This validates a {Entities::StatusMessage}.
    class StatusMessageValidator < Validation::Validator
      include Validation

      rule :author, %i(not_empty diaspora_id)

      rule :guid, :guid

      rule :photos, :not_nil

      rule :public, :boolean
    end
  end
end
