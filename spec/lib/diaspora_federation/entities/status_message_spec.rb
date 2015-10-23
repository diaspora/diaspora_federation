module DiasporaFederation
  describe Entities::StatusMessage do
    let(:photo1) { Entities::Photo.new(FactoryGirl.attributes_for(:photo_entity)) }
    let(:photo2) { Entities::Photo.new(FactoryGirl.attributes_for(:photo_entity)) }
    let(:location) { Entities::Location.new(FactoryGirl.attributes_for(:location_entity)) }
    let(:data) {
      {
        raw_message:           "this is such an interesting text",
        photos:                [photo1, photo2],
        location:              location,
        guid:                  FactoryGirl.generate(:guid),
        diaspora_id:           FactoryGirl.generate(:diaspora_id),
        public:                true,
        created_at:            Time.zone.now,
        provider_display_name: "something"
      }
    }

    let(:xml) {
      <<-XML
<status_message>
  <raw_message>#{data[:raw_message]}</raw_message>
  <photo>
    <guid>#{photo1.guid}</guid>
    <diaspora_handle>#{photo1.diaspora_id}</diaspora_handle>
    <public>#{photo1.public}</public>
    <created_at>#{photo1.created_at}</created_at>
    <remote_photo_path>#{photo1.remote_photo_path}</remote_photo_path>
    <remote_photo_name>#{photo1.remote_photo_name}</remote_photo_name>
    <text>#{photo1.text}</text>
    <status_message_guid>#{photo1.status_message_guid}</status_message_guid>
    <height>#{photo1.height}</height>
    <width>#{photo1.width}</width>
  </photo>
  <photo>
    <guid>#{photo2.guid}</guid>
    <diaspora_handle>#{photo2.diaspora_id}</diaspora_handle>
    <public>#{photo2.public}</public>
    <created_at>#{photo2.created_at}</created_at>
    <remote_photo_path>#{photo2.remote_photo_path}</remote_photo_path>
    <remote_photo_name>#{photo2.remote_photo_name}</remote_photo_name>
    <text>#{photo2.text}</text>
    <status_message_guid>#{photo2.status_message_guid}</status_message_guid>
    <height>#{photo2.height}</height>
    <width>#{photo2.width}</width>
  </photo>
  <location>
    <address>#{location.address}</address>
    <lat>#{location.lat}</lat>
    <lng>#{location.lng}</lng>
  </location>
  <guid>#{data[:guid]}</guid>
  <diaspora_handle>#{data[:diaspora_id]}</diaspora_handle>
  <public>#{data[:public]}</public>
  <created_at>#{data[:created_at]}</created_at>
  <provider_display_name>#{data[:provider_display_name]}</provider_display_name>
</status_message>
      XML
    }

    it_behaves_like "an Entity subclass" do
      let(:klass) { Entities::StatusMessage }
    end
  end
end
