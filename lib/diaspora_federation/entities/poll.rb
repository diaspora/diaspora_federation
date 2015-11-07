module DiasporaFederation
  module Entities
    class Poll < Entity
      property :guid
      property :question
      entity :poll_answers, [Entities::PollAnswer]
    end
  end
end
