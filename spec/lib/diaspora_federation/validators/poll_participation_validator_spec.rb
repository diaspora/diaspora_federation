module DiasporaFederation
  describe Validators::PollParticipationValidator do
    let(:entity) { :poll_participation_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a relayable validator"

    it_behaves_like "a diaspora id validator" do
      let(:property) { :diaspora_id }
      let(:mandatory) { true }
    end

    %i(guid poll_answer_guid).each do |prop|
      describe "##{prop}" do
        it_behaves_like "a guid validator" do
          let(:property) { prop }
        end
      end
    end
  end
end
