# frozen_string_literal: true

module DiasporaFederation
  module Validators
    # This validates a {Entities::PollParticipation}.
    class PollParticipationValidator < OptionalAwareValidator
      include Validation

      include RelayableValidator

      rule :poll_answer_guid, :guid
    end
  end
end
