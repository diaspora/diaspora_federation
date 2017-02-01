module DiasporaFederation
  describe Entities::RelatedEntity do
    let(:data) { Fabricate.attributes_for(:related_entity) }
    let(:string) { "RelatedEntity" }

    it_behaves_like "an Entity subclass"

    describe "#to_xml" do
      it "returns nil" do
        expect(described_class.new(data).to_xml).to be_nil
      end
    end
  end
end
