module DiasporaFederation
  describe Entities::Reshare do
    let(:root) { FactoryGirl.create(:post, author: bob) }
    let(:data) { FactoryGirl.attributes_for(:reshare_entity, root_guid: root.guid, root_author: bob.diaspora_id) }

    let(:xml) { <<-XML }
<reshare>
  <diaspora_handle>#{data[:author]}</diaspora_handle>
  <guid>#{data[:guid]}</guid>
  <created_at>#{data[:created_at].utc.iso8601}</created_at>
  <provider_display_name>#{data[:provider_display_name]}</provider_display_name>
  <root_diaspora_id>#{data[:root_author]}</root_diaspora_id>
  <root_guid>#{data[:root_guid]}</root_guid>
  <public>#{data[:public]}</public>
</reshare>
XML

    let(:json) { <<-JSON }
{
  "entity_type": "reshare",
  "entity_data": {
    "author": "#{data[:author]}",
    "guid": "#{data[:guid]}",
    "created_at": "#{data[:created_at].utc.iso8601}",
    "provider_display_name": "#{data[:provider_display_name]}",
    "root_author": "#{data[:root_author]}",
    "root_guid": "#{data[:root_guid]}",
    "public": #{data[:public]}
  }
}
JSON

    let(:string) { "Reshare:#{data[:guid]}:#{data[:root_guid]}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a JSON Entity"

    context "default values" do
      it "uses default values" do
        minimal_xml = <<-XML
<reshare>
  <author>#{data[:author]}</author>
  <guid>#{data[:guid]}</guid>
  <created_at>#{data[:created_at]}</created_at>
  <root_diaspora_id>#{data[:root_author]}</root_diaspora_id>
  <root_guid>#{data[:root_guid]}</root_guid>
</reshare>
XML

        parsed_instance = DiasporaFederation::Salmon::XmlPayload.unpack(Nokogiri::XML::Document.parse(minimal_xml).root)
        expect(parsed_instance.public).to be_truthy
        expect(parsed_instance.provider_display_name).to be_nil
      end
    end

    context "fetch root" do
      it "fetches the root post if it is not available already" do
        expect_callback(:fetch_related_entity, "Post", data[:root_guid]).and_return(nil)
        expect(Federation::Fetcher).to receive(:fetch_public).with(data[:root_author], "Post", data[:root_guid])

        Entities::Reshare.from_xml(Nokogiri::XML::Document.parse(xml).root)
      end
    end
  end
end
