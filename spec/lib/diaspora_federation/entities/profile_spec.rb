module DiasporaFederation
  describe Entities::Profile do
    let(:data) { FactoryGirl.attributes_for(:profile_entity) }

    let(:xml) {
      <<-XML
<profile>
  <diaspora_handle>#{data[:author]}</diaspora_handle>
  <first_name>#{data[:first_name]}</first_name>
  <last_name/>
  <image_url>#{data[:image_url]}</image_url>
  <image_url_medium>#{data[:image_url]}</image_url_medium>
  <image_url_small>#{data[:image_url]}</image_url_small>
  <birthday>#{data[:birthday]}</birthday>
  <gender>#{data[:gender]}</gender>
  <bio>#{data[:bio]}</bio>
  <location>#{data[:location]}</location>
  <searchable>#{data[:searchable]}</searchable>
  <nsfw>#{data[:nsfw]}</nsfw>
  <tag_string>#{data[:tag_string]}</tag_string>
</profile>
XML
    }
    let(:string) { "Profile:#{data[:author]}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    context "default values" do
      let(:minimal_xml) {
        <<-XML
<profile>
  <author>#{data[:author]}</author>
</profile>
        XML
      }

      it "uses default values" do
        parsed_instance = DiasporaFederation::Salmon::XmlPayload.unpack(Nokogiri::XML::Document.parse(minimal_xml).root)
        expect(parsed_instance.first_name).to be_nil
        expect(parsed_instance.last_name).to be_nil
        expect(parsed_instance.image_url).to be_nil
        expect(parsed_instance.image_url_medium).to be_nil
        expect(parsed_instance.image_url_small).to be_nil
        expect(parsed_instance.birthday).to be_nil
        expect(parsed_instance.gender).to be_nil
        expect(parsed_instance.bio).to be_nil
        expect(parsed_instance.location).to be_nil
        expect(parsed_instance.searchable).to be_truthy
        expect(parsed_instance.nsfw).to be_falsey
        expect(parsed_instance.tag_string).to be_nil
      end
    end
  end
end
