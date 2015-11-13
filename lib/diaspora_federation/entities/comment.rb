module DiasporaFederation
  module Entities
    class Comment < Entity
      property :guid
      include Relayable
      property :text
      property :diaspora_id, xml_name: :diaspora_handle
    end
  end
end
