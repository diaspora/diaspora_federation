module DiasporaFederation
  module Entities
    class Message < Entity
      property :guid
      include Relayable
      property :text
      property :created_at, default: -> { Time.now.utc }
      property :diaspora_id, xml_name: :diaspora_handle
      property :conversation_guid
    end
  end
end
