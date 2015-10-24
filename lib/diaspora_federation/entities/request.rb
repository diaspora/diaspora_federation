module DiasporaFederation
  module Entities
    class Request < Entity
      property :sender_id, xml_name: :sender_handle
      property :recipient_id, xml_name: :recipient_handle
    end
  end
end
