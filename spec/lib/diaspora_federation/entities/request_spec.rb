module DiasporaFederation
  describe Entities::Request do
    let(:data) { FactoryGirl.attributes_for(:request_entity) }

    let(:xml) {
      <<-XML
<request>
  <sender_handle>#{data[:author]}</sender_handle>
  <recipient_handle>#{data[:recipient]}</recipient_handle>
</request>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
