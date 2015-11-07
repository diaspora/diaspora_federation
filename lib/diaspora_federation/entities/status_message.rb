module DiasporaFederation
  module Entities
    class StatusMessage < Entity
      property :raw_message
      entity :photos, [Entities::Photo], default: []
      entity :location, Entities::Location, default: nil
      entity :poll, Entities::Poll, default: nil
      property :guid
      property :diaspora_id, xml_name: :diaspora_handle
      property :public, default: false
      property :created_at, default: -> { Time.now.utc }
      property :provider_display_name, default: nil
    end
  end
end
