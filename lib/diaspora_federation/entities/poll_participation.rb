module DiasporaFederation
  module Entities
    class PollParticipation < Entity
      property :guid
      include Relayable
      property :diaspora_id, xml_name: :diaspora_handle
      property :poll_answer_guid
    end
  end
end
