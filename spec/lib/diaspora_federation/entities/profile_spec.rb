module DiasporaFederation
  describe Entities::Profile do
    let(:data) { Fabricate.attributes_for(:profile_entity) }

    let(:xml) { <<-XML }
<profile>
  <author>#{data[:author]}</author>
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
  <public>#{data[:public]}</public>
  <nsfw>#{data[:nsfw]}</nsfw>
  <tag_string>#{data[:tag_string]}</tag_string>
</profile>
XML

    let(:json) { <<-JSON }
{
  "entity_type": "profile",
  "entity_data": {
    "author": "#{data[:author]}",
    "first_name": "#{data[:first_name]}",
    "last_name": "",
    "image_url": "#{data[:image_url]}",
    "image_url_medium": "#{data[:image_url]}",
    "image_url_small": "#{data[:image_url]}",
    "birthday": "#{data[:birthday]}",
    "gender": "#{data[:gender]}",
    "bio": "#{data[:bio]}",
    "location": "#{data[:location]}",
    "searchable": #{data[:searchable]},
    "public": #{data[:public]},
    "nsfw": #{data[:nsfw]},
    "tag_string": "#{data[:tag_string]}"
  }
}
JSON

    let(:string) { "Profile:#{data[:author]}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a JSON Entity"

    context "default values" do
      it "uses default values" do
        minimal_xml = <<-XML
<profile>
  <author>#{data[:author]}</author>
</profile>
XML

        parsed_instance = DiasporaFederation::Salmon::XmlPayload.unpack(Nokogiri::XML(minimal_xml).root)
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
        expect(parsed_instance.public).to be_falsey
        expect(parsed_instance.nsfw).to be_falsey
        expect(parsed_instance.tag_string).to be_nil
      end
    end
  end
end
