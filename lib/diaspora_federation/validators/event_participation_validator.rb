module DiasporaFederation
  module Validators
    # This validates a {Entities::EventParticipation}.
    class EventParticipationValidator < OptionalAwareValidator
      include Validation

      include RelayableValidator

      rule :status, regular_expression: {regex: /\A(accepted|declined|tentative)\z/}
    end
  end
end
