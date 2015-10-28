module DiasporaFederation
  describe Entities::Request do
    let(:data) {
      {sender_id:    "alice@somepod.org",
       recipient_id: "bob@otherpod.net"}
    }

    let(:xml) {
      <<-XML
<request>
  <sender_handle>alice@somepod.org</sender_handle>
  <recipient_handle>bob@otherpod.net</recipient_handle>
</request>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
