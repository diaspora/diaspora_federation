module DiasporaFederation
  describe Validators::RetractionValidator do
    let(:entity) { :retraction_entity }
    it_behaves_like "a common validator"

    it_behaves_like "a guid validator" do
      let(:property) { :post_guid }
    end

    it_behaves_like "a diaspora id validator" do
      let(:property) { :diaspora_id }
      let(:mandatory) { true }
    end

    context "#type" do
      it_behaves_like "a property that mustn't be empty" do
        let(:property) { :type }
      end
    end
  end
end
