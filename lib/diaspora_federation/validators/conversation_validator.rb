module DiasporaFederation
  module Validators
    class ConversationValidator < Validation::Validator
      include Validation

      rule :guid, :guid

      rule :diaspora_id, %i(not_empty diaspora_id)

      rule :participant_ids, diaspora_id_count: {maximum: 20}
    end
  end
end
