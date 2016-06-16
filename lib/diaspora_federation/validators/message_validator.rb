module DiasporaFederation
  module Validators
    # This validates a {Entities::Message}
    class MessageValidator < Validation::Validator
      include Validation

      rule :author, %i(not_empty diaspora_id)
      rule :guid, :guid
      rule :conversation_guid, :guid
    end
  end
end
