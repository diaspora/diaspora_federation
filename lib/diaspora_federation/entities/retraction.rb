module DiasporaFederation
  module Entities
    class Retraction < Entity
      property :post_guid
      property :diaspora_id, xml_name: :diaspora_handle
      property :type
    end
  end
end
