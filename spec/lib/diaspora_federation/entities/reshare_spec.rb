module DiasporaFederation
  describe Entities::Reshare do
    let(:data) { FactoryGirl.attributes_for(:reshare_entity) }

    let(:xml) {
      <<-XML
<reshare>
  <root_diaspora_id>#{data[:root_author]}</root_diaspora_id>
  <root_guid>#{data[:root_guid]}</root_guid>
  <diaspora_handle>#{data[:author]}</diaspora_handle>
  <guid>#{data[:guid]}</guid>
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
