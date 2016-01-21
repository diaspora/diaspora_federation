module DiasporaFederation
  describe Entities::PollParticipation do
    let(:data) { Test.attributes_with_signatures(:poll_participation_entity) }

    let(:xml) {
      <<-XML
<poll_participation>
  <guid>#{data[:guid]}</guid>
  <parent_guid>#{data[:parent_guid]}</parent_guid>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
  <author_signature>#{data[:author_signature]}</author_signature>
  <diaspora_handle>#{data[:diaspora_id]}</diaspora_handle>
  <poll_answer_guid>#{data[:poll_answer_guid]}</poll_answer_guid>
</poll_participation>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a relayable Entity"

    describe "#target_type" do
      it "returns \"Poll\" as target type" do
        expect(described_class.new(data).target_type).to eq("Poll")
      end
    end
  end
end
