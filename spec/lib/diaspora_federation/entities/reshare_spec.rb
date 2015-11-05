module DiasporaFederation
  describe Entities::Reshare do
    before do
      @datetime = DateTime.now.utc
    end

    let(:data) {
      {root_diaspora_id:      "robert_root@pod.example.tld",
       root_guid:             "fedcba9876543210",
       guid:                  "0123456789abcdef",
       diaspora_id:           "alice@diaspora.domain.tld",
       public:                true,
       created_at:            @datetime,
       provider_display_name: "mobile"}
    }

    let(:xml) {
      <<-XML
<reshare>
  <root_diaspora_id>robert_root@pod.example.tld</root_diaspora_id>
  <root_guid>fedcba9876543210</root_guid>
  <guid>0123456789abcdef</guid>
  <diaspora_handle>alice@diaspora.domain.tld</diaspora_handle>
  <public>true</public>
  <created_at>#{@datetime}</created_at>
  <provider_display_name>mobile</provider_display_name>
</reshare>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
