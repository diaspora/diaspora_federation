module DiasporaFederation
  module Entities
    class Message < Entity
      property :guid
      property :parent_guid
      property :parent_author_signature
      property :author_signature
      property :text
      property :created_at, default: -> { Time.now.utc }
      property :diaspora_id, xml_name: :diaspora_handle
      property :conversation_guid
    end
  end
end
