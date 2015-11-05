module DiasporaFederation
  module Entities
    class SignedRetraction < Entity
      property :target_guid
      property :target_type
      property :sender_id, xml_name: :sender_handle
      property :target_author_signature
    end
  end
end
