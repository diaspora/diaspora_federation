module DiasporaFederation
  describe Validators::MessageValidator do
    let(:entity) { :message_entity }
    it_behaves_like "a common validator"

    it_behaves_like "a relayable validator"

    describe "#conversation_guid" do
      it_behaves_like "a guid validator" do
        let(:property) { :conversation_guid }
      end
    end
  end
end
