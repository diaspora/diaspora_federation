module DiasporaFederation
  describe Entities::Participation do
    let(:parent) { FactoryGirl.create(:post, author: bob) }
    let(:data) {
      FactoryGirl.build(
        :participation_entity,
        diaspora_id: alice.diaspora_id,
        parent_guid: parent.guid,
        parent_type: parent.entity_type
      ).to_signed_h
    }

    let(:xml) {
      <<-XML
<participation>
  <diaspora_handle>#{data[:diaspora_id]}</diaspora_handle>
  <guid>#{data[:guid]}</guid>
  <parent_guid>#{parent.guid}</parent_guid>
  <author_signature>#{data[:author_signature]}</author_signature>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
  <target_type>#{parent.entity_type}</target_type>
</participation>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a relayable Entity"

    describe "#parent_type" do
      it "returns data[:parent_type] as parent type" do
        expect(described_class.new(data).parent_type).to eq(data[:parent_type])
      end
    end
  end
end
