module DiasporaFederation
  module Entities
    class Photo < Entity
      property :guid
      property :diaspora_id, xml_name: :diaspora_handle
      property :public, default: false
      property :created_at, default: -> { Time.now.utc }
      property :remote_photo_path
      property :remote_photo_name
      property :text, default: nil
      property :status_message_guid
      property :height
      property :width
    end
  end
end
