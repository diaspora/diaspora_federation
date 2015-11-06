module DiasporaFederation
  module Validators
    class PollParticipationValidator < Validation::Validator
      include Validation

      rule :guid, :guid

      rule :parent_guid, :guid

      rule :parent_author_signature, :not_empty

      rule :diaspora_id, %i(not_empty diaspora_id)

      rule :poll_answer_guid, :guid
    end
  end
end
