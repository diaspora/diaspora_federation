module DiasporaFederation
  describe Entities::AccountDeletion do
    let(:data) { {diaspora_id: "me@goes.byebye.tld"} }

    let(:xml) {
      <<-XML
<account_deletion>
  <diaspora_handle>me@goes.byebye.tld</diaspora_handle>
</account_deletion>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
