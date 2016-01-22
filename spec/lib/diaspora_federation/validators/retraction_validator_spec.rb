module DiasporaFederation
  describe Validators::RetractionValidator do
    let(:entity) { :retraction_entity }
    it_behaves_like "a common validator"

    it_behaves_like "a guid validator" do
      let(:property) { :target_guid }
    end

    it_behaves_like "a diaspora id validator" do
      let(:property) { :diaspora_id }
      let(:mandatory) { true }
    end

    describe "#target_type" do
      it_behaves_like "a property that mustn't be empty" do
        let(:property) { :target_type }
      end
    end
  end
end
