module DiasporaFederation
  describe Entities::RelayableRetraction do
    let(:data) {
      {parent_author_signature: "AAAAAA=",
       target_guid:             "0123456789abcdef",
       target_type:             "Comment",
       sender_id:               "luke@diaspora.example.tld",
       target_author_signature: "BBBBBB="}
    }

    let(:xml) {
      <<-XML
<relayable_retraction>
  <parent_author_signature>AAAAAA=</parent_author_signature>
  <target_guid>0123456789abcdef</target_guid>
  <target_type>Comment</target_type>
  <sender_handle>luke@diaspora.example.tld</sender_handle>
  <target_author_signature>BBBBBB=</target_author_signature>
</relayable_retraction>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
