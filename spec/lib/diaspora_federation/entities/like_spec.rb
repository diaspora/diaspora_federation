module DiasporaFederation
  describe Entities::Like do
    let(:data) {
      {positive:                true,
       guid:                    "0123456789abcdef",
       target_type:             "Post",
       parent_guid:             "fedcba9876543210",
       parent_author_signature: "BBBBBB==",
       author_signature:        "AAAAAA==",
       diaspora_id:             "luke@diaspora.example.tld"}
    }

    let(:xml) {
      <<-XML
<like>
  <positive>true</positive>
  <guid>0123456789abcdef</guid>
  <target_type>Post</target_type>
  <parent_guid>fedcba9876543210</parent_guid>
  <parent_author_signature>BBBBBB==</parent_author_signature>
  <author_signature>AAAAAA==</author_signature>
  <diaspora_handle>luke@diaspora.example.tld</diaspora_handle>
</like>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
