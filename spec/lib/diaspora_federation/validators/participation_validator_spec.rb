module DiasporaFederation
  describe Validators::ParticipationValidator do
    let(:entity) { :participation_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a diaspora* ID validator" do
      let(:property) { :author }
    end

    describe "#guid" do
      it_behaves_like "a guid validator" do
        let(:property) { :guid }
      end
    end

    describe "#parent_guid" do
      it_behaves_like "a guid validator" do
        let(:property) { :parent_guid }
      end
    end

    describe "#parent_type" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :parent_type }
        let(:wrong_values) { [nil, "", "any", "Postxxx", "post"] }
        let(:correct_values) { ["Post"] }
      end
    end
  end
end
