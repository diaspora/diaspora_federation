module DiasporaFederation
  describe Validators::PersonValidator do
    let(:entity) { :person_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a diaspora id validator" do
      let(:property) { :diaspora_id }
      let(:mandatory) { true }
    end

    it_behaves_like "a guid validator" do
      let(:property) { :guid }
    end

    describe "#url" do
      it_behaves_like "a url validator without path" do
        let(:property) { :url }
      end
    end

    describe "#profile" do
      it_behaves_like "a property with data-types restriction" do
        let(:property) { :profile }
        let(:wrong_values) { [nil] }
        let(:correct_values) { [] }
      end
    end

    it_behaves_like "a public key validator" do
      let(:property) { :exported_key }
    end
  end
end
