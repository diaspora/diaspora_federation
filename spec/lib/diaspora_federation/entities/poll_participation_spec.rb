module DiasporaFederation
  describe Entities::PollParticipation do
    let(:parent) { FactoryGirl.create(:poll, author: bob) }
    let(:data) {
      FactoryGirl.build(:poll_participation_entity, diaspora_id: alice.diaspora_id, parent_guid: parent.guid).to_h
    }

    let(:xml) {
      <<-XML
<poll_participation>
  <diaspora_handle>#{data[:diaspora_id]}</diaspora_handle>
  <guid>#{data[:guid]}</guid>
  <parent_guid>#{parent.guid}</parent_guid>
  <author_signature>#{data[:author_signature]}</author_signature>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
  <poll_answer_guid>#{data[:poll_answer_guid]}</poll_answer_guid>
</poll_participation>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a relayable Entity"

    describe "#parent_type" do
      it "returns \"Poll\" as parent type" do
        expect(described_class.new(data).parent_type).to eq("Poll")
      end
    end
  end
end
