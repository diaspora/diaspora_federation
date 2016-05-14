module DiasporaFederation
  describe Entities::Reshare do
    let(:data) { FactoryGirl.attributes_for(:reshare_entity) }

    let(:xml) {
      <<-XML
<reshare>
  <diaspora_handle>#{data[:author]}</diaspora_handle>
  <guid>#{data[:guid]}</guid>
  <created_at>#{data[:created_at]}</created_at>
  <provider_display_name>#{data[:provider_display_name]}</provider_display_name>
  <root_diaspora_id>#{data[:root_author]}</root_diaspora_id>
  <root_guid>#{data[:root_guid]}</root_guid>
  <public>#{data[:public]}</public>
</reshare>
XML
    }
    let(:string) { "Reshare:#{data[:guid]}:#{data[:root_guid]}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    context "default values" do
      let(:minimal_xml) {
        <<-XML
<reshare>
  <author>#{data[:author]}</author>
  <guid>#{data[:guid]}</guid>
  <created_at>#{data[:created_at]}</created_at>
  <root_diaspora_id>#{data[:root_author]}</root_diaspora_id>
  <root_guid>#{data[:root_guid]}</root_guid>
</reshare>
        XML
      }

      it "uses default values" do
        parsed_instance = DiasporaFederation::Salmon::XmlPayload.unpack(Nokogiri::XML::Document.parse(minimal_xml).root)
        expect(parsed_instance.public).to be_truthy
        expect(parsed_instance.provider_display_name).to be_nil
      end
    end
  end
end
