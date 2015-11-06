module DiasporaFederation
  module Entities
    class PollParticipation < Entity
      property :guid
      property :parent_guid
      property :parent_author_signature
      property :diaspora_id, xml_name: :diaspora_handle
      property :poll_answer_guid
    end
  end
end
