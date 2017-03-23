module DiasporaFederation
  describe Entities::Location do
    let(:data) { FactoryGirl.attributes_for(:location_entity) }

    let(:xml) { <<-XML }
<location>
  <address>#{data[:address]}</address>
  <lat>#{data[:lat]}</lat>
  <lng>#{data[:lng]}</lng>
</location>
XML

    let(:json) { <<-JSON }
{
  "entity_type": "location",
  "entity_data": {
    "address": "#{data[:address]}",
    "lat": "#{data[:lat]}",
    "lng": "#{data[:lng]}"
  }
}
JSON

    let(:string) { "Location" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a JSON Entity"
  end
end
