module DiasporaFederation
  module Validators
    # This validates a {Entities::Message}
    class MessageValidator < Validation::Validator
      include Validation

      include RelayableValidator

      rule :conversation_guid, :guid
    end
  end
end
