module DiasporaFederation
  describe Validators::ConversationValidator do
    let(:entity) { :conversation_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a diaspora id validator" do
      let(:property) { :author }
      let(:mandatory) { true }
    end

    it_behaves_like "a guid validator" do
      let(:property) { :guid }
    end

    describe "#messages" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :messages }
        let(:wrong_values) { [nil] }
        let(:correct_values) { [[], [FactoryGirl.build(:message_entity)]] }
      end
    end

    describe "#participant_ids" do
      # must not contain more than 20 participant handles
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :participants }
        let(:wrong_values) { [Array.new(21) { FactoryGirl.generate(:diaspora_id) }.join(";")] }
        let(:correct_values) { [Array.new(20) { FactoryGirl.generate(:diaspora_id) }.join(";")] }
      end
    end
  end
end
