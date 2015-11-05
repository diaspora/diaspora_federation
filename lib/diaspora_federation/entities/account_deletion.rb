module DiasporaFederation
  module Entities
    class AccountDeletion < Entity
      property :diaspora_id, xml_name: :diaspora_handle
    end
  end
end
