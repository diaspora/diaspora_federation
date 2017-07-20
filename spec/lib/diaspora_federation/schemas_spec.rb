require "diaspora_federation/schemas"

module DiasporaFederation
  describe Schemas do
    describe ".federation_entities" do
      it "returns the parsed federation_entities JSON schema" do
        schema = DiasporaFederation::Schemas.federation_entities
        expect(schema).to be_a(Hash)
        expect(schema["id"]).to eq(DiasporaFederation::Schemas::FEDERATION_ENTITIES_URI)
      end
    end
  end
end
