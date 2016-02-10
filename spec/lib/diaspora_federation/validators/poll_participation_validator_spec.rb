module DiasporaFederation
  describe Validators::PollParticipationValidator do
    let(:entity) { :poll_participation_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a relayable validator"

    describe "#poll_answer_guid" do
      it_behaves_like "a guid validator" do
        let(:property) { :poll_answer_guid }
      end
    end
  end
end
