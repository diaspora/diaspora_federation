module DiasporaFederation
  describe Entities::Comment do
    let(:parent) { FactoryGirl.create(:post, author: bob) }
    let(:data) { FactoryGirl.build(:comment_entity, diaspora_id: alice.diaspora_id, parent_guid: parent.guid).to_h }

    let(:xml) {
      <<-XML
<comment>
  <guid>#{data[:guid]}</guid>
  <parent_guid>#{parent.guid}</parent_guid>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
  <author_signature>#{data[:author_signature]}</author_signature>
  <text>#{data[:text]}</text>
  <diaspora_handle>#{data[:diaspora_id]}</diaspora_handle>
</comment>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a relayable Entity"

    describe "#parent_type" do
      it "returns \"Post\" as parent type" do
        expect(described_class.new(data).parent_type).to eq("Post")
      end
    end
  end
end
