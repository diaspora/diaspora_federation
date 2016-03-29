module DiasporaFederation
  describe Validators::RetractionValidator do
    let(:entity) { :retraction_entity }
    it_behaves_like "a common validator"

    it_behaves_like "a guid validator" do
      let(:property) { :target_guid }
    end

    it_behaves_like "a diaspora id validator" do
      let(:property) { :author }
      let(:mandatory) { true }
    end

    describe "#target_type" do
      it_behaves_like "a property that mustn't be empty" do
        let(:property) { :target_type }
      end
    end

    describe "#target" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :target }
        let(:wrong_values) { [nil] }
        let(:correct_values) { [FactoryGirl.build(:related_entity)] }
      end
    end
  end
end
