module DiasporaFederation
  describe Validators::ConversationValidator do
    let(:entity) { :conversation_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a diaspora id validator" do
      let(:property) { :diaspora_id }
      let(:mandatory) { true }
    end

    it_behaves_like "a guid validator" do
      let(:property) { :guid }
    end

    describe "participant_ids" do
      # must not contain more than 20 participant handles
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :participant_ids }
        let(:wrong_values) { [Array.new(21) { FactoryGirl.generate(:diaspora_id) }.join(";")] }
        let(:correct_values) { [Array.new(20) { FactoryGirl.generate(:diaspora_id) }.join(";")] }
      end
    end
  end
end
