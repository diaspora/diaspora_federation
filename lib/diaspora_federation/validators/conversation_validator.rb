module DiasporaFederation
  module Validators
    # This validates a {Entities::Conversation}.
    class ConversationValidator < Validation::Validator
      include Validation

      rule :guid, :guid

      rule :messages, :not_nil

      rule :author, %i(not_empty diaspora_id)

      rule :participants, diaspora_id_count: {maximum: 20}
    end
  end
end
