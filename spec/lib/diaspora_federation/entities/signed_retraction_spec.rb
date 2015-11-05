module DiasporaFederation
  describe Entities::SignedRetraction do
    let(:data) {
      {target_guid:             "0123456789abcdef",
       target_type:             "StatusMessage",
       sender_id:               "luke@diaspora.example.tld",
       target_author_signature: "AAAAAA=="}
    }

    let(:xml) {
      <<-XML
<signed_retraction>
  <target_guid>0123456789abcdef</target_guid>
  <target_type>StatusMessage</target_type>
  <sender_handle>luke@diaspora.example.tld</sender_handle>
  <target_author_signature>AAAAAA==</target_author_signature>
</signed_retraction>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
