module DiasporaFederation
  module Entities
    class Participation < Entity
      property :guid
      property :target_type
      include Relayable
      property :diaspora_id, xml_name: :diaspora_handle
    end
  end
end
