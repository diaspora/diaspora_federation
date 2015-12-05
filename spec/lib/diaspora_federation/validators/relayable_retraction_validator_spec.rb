module DiasporaFederation
  describe Validators::RelayableRetractionValidator do
    let(:entity) { :relayable_retraction_entity }
    it_behaves_like "a common validator"

    it_behaves_like "a diaspora id validator" do
      let(:property) { :diaspora_id }
      let(:mandatory) { true }
    end

    it_behaves_like "a guid validator" do
      let(:property) { :target_guid }
    end

    describe "#target_type" do
      it_behaves_like "a property that mustn't be empty" do
        let(:property) { :target_type }
      end
    end
  end
end
