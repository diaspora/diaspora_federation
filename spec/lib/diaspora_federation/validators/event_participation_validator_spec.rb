module DiasporaFederation
  describe Validators::EventParticipationValidator do
    let(:entity) { :event_participation_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a relayable validator"

    describe "#status" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :status }
        let(:wrong_values) { ["", "yes", "foobar"] }
        let(:correct_values) { %w[accepted declined tentative] }
      end
    end
  end
end
