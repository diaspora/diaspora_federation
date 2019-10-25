# frozen_string_literal: true

module DiasporaFederation
  describe Validators::LikeValidator do
    let(:entity) { :like_entity }
    it_behaves_like "a common validator"

    it_behaves_like "a relayable validator"

    describe "#parent_type" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :parent_type }
        let(:wrong_values) { [nil, "", "any", "Postxxx", "post"] }
        let(:correct_values) { %w[Post Comment] }
      end
    end
  end
end
