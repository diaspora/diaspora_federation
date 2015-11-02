module DiasporaFederation
  describe Entities::Participation do
    let(:data) {
      {guid:                    "0123456789abcdef",
       target_type:             "Post",
       parent_guid:             "fedcba9876543210",
       parent_author_signature: "BBBBBB==",
       author_signature:        "AAAAAA==",
       diaspora_id:             "luke@diaspora.example.tld"}
    }

    let(:xml) {
      <<-XML
<participation>
  <guid>#{data[:guid]}</guid>
  <target_type>#{data[:target_type]}</target_type>
  <parent_guid>#{data[:parent_guid]}</parent_guid>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
  <author_signature>#{data[:author_signature]}</author_signature>
  <diaspora_handle>#{data[:diaspora_id]}</diaspora_handle>
</participation>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
