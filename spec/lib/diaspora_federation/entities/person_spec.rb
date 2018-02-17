module DiasporaFederation
  describe Entities::Person do
    let(:data) { Fabricate.attributes_for(:person_entity) }

    let(:xml) { <<-XML }
<person>
  <guid>#{data[:guid]}</guid>
  <author>#{data[:author]}</author>
  <url>#{data[:url]}</url>
  <profile>
    <author>#{data[:profile].author}</author>
    <edited_at>#{data[:profile].edited_at.utc.iso8601}</edited_at>
    <first_name>#{data[:profile].first_name}</first_name>
    <image_url>#{data[:profile].image_url}</image_url>
    <image_url_medium>#{data[:profile].image_url}</image_url_medium>
    <image_url_small>#{data[:profile].image_url}</image_url_small>
    <bio>#{data[:profile].bio}</bio>
    <birthday>#{data[:profile].birthday}</birthday>
    <gender>#{data[:profile].gender}</gender>
    <location>#{data[:profile].location}</location>
    <searchable>#{data[:profile].searchable}</searchable>
    <public>#{data[:profile].public}</public>
    <nsfw>#{data[:profile].nsfw}</nsfw>
    <tag_string>#{data[:profile].tag_string}</tag_string>
  </profile>
  <exported_key>#{data[:exported_key]}</exported_key>
</person>
XML

    let(:string) { "Person:#{data[:guid]}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
