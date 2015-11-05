module DiasporaFederation
  describe Entities::Retraction do
    let(:data) {
      {post_guid:   "0123456789abcdef",
       diaspora_id: "luke@diaspora.example.tld",
       type:        "StatusMessage"}
    }

    let(:xml) {
      <<-XML
<retraction>
  <post_guid>0123456789abcdef</post_guid>
  <diaspora_handle>luke@diaspora.example.tld</diaspora_handle>
  <type>StatusMessage</type>
</retraction>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
