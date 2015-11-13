module DiasporaFederation
  module Validators
    class MessageValidator < Validation::Validator
      include Validation

      rule :guid, :guid

      include RelayableValidator

      rule :diaspora_id, %i(not_empty diaspora_id)

      rule :conversation_guid, :guid
    end
  end
end
