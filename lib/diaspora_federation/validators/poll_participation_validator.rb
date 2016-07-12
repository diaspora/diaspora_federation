module DiasporaFederation
  module Validators
    # This validates a {Entities::PollParticipation}.
    class PollParticipationValidator < Validation::Validator
      include Validation

      include RelayableValidator

      rule :poll_answer_guid, :guid
    end
  end
end
