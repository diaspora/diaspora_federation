module DiasporaFederation
  describe Entities::Comment do
    let(:data) {
      {guid:                    "0123456789abcdef",
       parent_guid:             "fedcba9876543210",
       parent_author_signature: "BBBBBB==",
       author_signature:        "AAAAAA==",
       text:                    "my comment text",
       diaspora_id:             "bob@pod.somedomain.tld"}
    }

    let(:xml) {
      <<-XML
<comment>
  <guid>0123456789abcdef</guid>
  <parent_guid>fedcba9876543210</parent_guid>
  <parent_author_signature>BBBBBB==</parent_author_signature>
  <author_signature>AAAAAA==</author_signature>
  <text>my comment text</text>
  <diaspora_handle>bob@pod.somedomain.tld</diaspora_handle>
</comment>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
