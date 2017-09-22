module DiasporaFederation
  describe Entities::RelatedEntity do
    let(:data) { Fabricate.attributes_for(:related_entity) }
    let(:string) { "RelatedEntity" }

    it_behaves_like "an Entity subclass"

    describe "#root" do
      it "returns self if it's already the root" do
        entity = Fabricate(:related_entity, parent: nil)
        expect(entity.root).to eq(entity)
      end

      it "returns the root entity if the current entity has parents" do
        root = Fabricate(:related_entity, parent: nil)
        parent = Fabricate(:related_entity, parent: root)
        entity = Fabricate(:related_entity, parent: parent)
        expect(entity.root).to eq(root)
      end
    end

    describe ".fetch" do
      let(:guid) { Fabricate.sequence(:guid) }
      let(:entity) { Fabricate(:related_entity) }

      it "fetches the entity from the backend" do
        expect_callback(:fetch_related_entity, "Entity", guid).and_return(entity)
        expect(Federation::Fetcher).not_to receive(:fetch_public)

        expect(described_class.fetch(entity.author, "Entity", guid)).to eq(entity)
      end

      it "fetches the entity from remote if not found on backend" do
        expect_callback(:fetch_related_entity, "Entity", guid).ordered.and_return(nil)
        expect(Federation::Fetcher).to receive(:fetch_public).ordered.with(entity.author, "Entity", guid)
        expect_callback(:fetch_related_entity, "Entity", guid).ordered.and_return(entity)

        expect(described_class.fetch(entity.author, "Entity", guid)).to eq(entity)
      end
    end

    describe "#to_xml" do
      it "returns nil" do
        expect(described_class.new(data).to_xml).to be_nil
      end
    end

    describe "#to_json" do
      it "returns nil" do
        expect(described_class.new(data).to_json).to be_nil
      end
    end
  end
end
