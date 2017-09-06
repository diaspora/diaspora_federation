module DiasporaFederation
  describe Validators::ReshareValidator do
    let(:entity) { :reshare_entity }
    it_behaves_like "a common validator"

    describe "#author" do
      it_behaves_like "a diaspora* ID validator" do
        let(:property) { :author }
        let(:mandatory) { true }
      end
    end

    describe "#guid" do
      it_behaves_like "a guid validator" do
        let(:property) { :guid }
      end
    end

    describe "#root_guid" do
      it_behaves_like "a nilable guid validator" do
        let(:property) { :root_guid }
      end
    end

    describe "#root_author" do
      it_behaves_like "a diaspora* ID validator" do
        let(:property) { :root_author }
        let(:mandatory) { false }
      end
    end

    it_behaves_like "a boolean validator" do
      let(:property) { :public }
    end

    describe "#text" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :text }
        let(:wrong_values) { ["a" * 65_536] }
        let(:correct_values) { ["a" * 65_535, nil, ""] }
      end
    end
  end
end
