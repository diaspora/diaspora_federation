module DiasporaFederation
  module Validators
    # This validates a {Entities::PollParticipation}
    class PollParticipationValidator < Validation::Validator
      include Validation

      rule :guid, :guid

      include RelayableValidator

      rule :diaspora_id, %i(not_empty diaspora_id)

      rule :poll_answer_guid, :guid
    end
  end
end
