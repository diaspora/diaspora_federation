module DiasporaFederation
  describe Validators::CommentValidator do
    let(:entity) { :comment_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a relayable validator"

    describe "#text" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :text }
        let(:wrong_values) { ["", "a" * 65_536] }
        let(:correct_values) { ["a" * 65_535] }
      end
    end
  end
end
