module DiasporaFederation
  module Entities
    class Conversation < Entity
      property :guid
      property :subject
      property :created_at, default: -> { Time.now.utc }
      entity :messages, [Entities::Message]
      property :diaspora_id, xml_name: :diaspora_handle
      property :participant_ids, xml_name: :participant_handles
    end
  end
end
