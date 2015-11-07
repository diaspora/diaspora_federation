module DiasporaFederation
  describe Validators::PollValidator do
    let(:entity) { :poll_entity }

    it_behaves_like "a common validator"

    describe "#guid" do
      it_behaves_like "a guid validator" do
        let(:property) { :guid }
      end
    end

    describe "#question" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :question }
        let(:wrong_values) { [nil, "", "a" * 256] }
        let(:correct_values) { ["a" * 255] }
      end
    end
  end
end
