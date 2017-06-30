module DiasporaFederation
  describe Parsers::RelayableJsonParser do
    describe ".parse" do
      let(:entity_class) { Entities::SomeRelayable }
      let(:json_parser) { Parsers::RelayableJsonParser.new(entity_class) }
      include_examples ".parse parse error",
                       "Required property is missing in JSON object: property_order",
                       '{"entity_type": "some_relayable", "entity_data": {}}'

      it "returns property order as a second argument" do
        json = JSON.parse <<-JSON
{
  "entity_type": "some_relayable",
  "property_order": ["property", "guid", "author"],
  "entity_data": {
    "author": "id@example.tld",
    "guid": "im a guid",
    "property": "value"
  }
}
JSON
        parsed_data = json_parser.parse(json)
        expect(parsed_data[0]).to be_a(Hash)
        expect(parsed_data[0][:guid]).to eq("im a guid")
        expect(parsed_data[0][:property]).to eq("value")
        expect(parsed_data[0][:author]).to eq("id@example.tld")
        expect(parsed_data[1]).to eq(%w[property guid author])
      end
    end
  end
end
