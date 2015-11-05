module DiasporaFederation
  module Entities
    class Comment < Entity
      property :guid
      property :parent_guid
      property :parent_author_signature
      property :author_signature
      property :text
      property :diaspora_id, xml_name: :diaspora_handle
    end
  end
end
