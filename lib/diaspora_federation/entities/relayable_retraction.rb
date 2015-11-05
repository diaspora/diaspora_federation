module DiasporaFederation
  module Entities
    class RelayableRetraction < Entity
      property :parent_author_signature
      property :target_guid
      property :target_type
      property :sender_id, xml_name: :sender_handle
      property :target_author_signature
    end
  end
end
