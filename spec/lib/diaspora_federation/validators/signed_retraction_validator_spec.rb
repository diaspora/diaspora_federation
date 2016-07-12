module DiasporaFederation
  describe Validators::SignedRetractionValidator do
    let(:entity) { :signed_retraction_entity }
    it_behaves_like "a common validator"

    it_behaves_like "a diaspora* ID validator" do
      let(:property) { :author }
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

    describe "#target" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :target }
        let(:wrong_values) { [nil] }
        let(:correct_values) { [FactoryGirl.build(:related_entity)] }
      end
    end
  end
end
