module DiasporaFederation
  describe Entities::Reshare do
    let(:data) { FactoryGirl.attributes_for(:reshare_entity) }

    let(:xml) {
      <<-XML
<reshare>
  <root_diaspora_id>#{data[:root_diaspora_id]}</root_diaspora_id>
  <root_guid>#{data[:root_guid]}</root_guid>
  <guid>#{data[:guid]}</guid>
  <diaspora_handle>#{data[:diaspora_id]}</diaspora_handle>
  <public>#{data[:public]}</public>
  <created_at>#{data[:created_at]}</created_at>
  <provider_display_name>#{data[:provider_display_name]}</provider_display_name>
</reshare>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
