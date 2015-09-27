module DiasporaFederation
  describe Entities::Profile do
    let(:data) { FactoryGirl.attributes_for(:profile_entity) }
    let(:klass) { Entities::Profile }

    let(:xml) {
      <<-XML
<profile>
  <diaspora_handle>#{data[:diaspora_id]}</diaspora_handle>
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

    it_behaves_like "an Entity subclass"
  end
end
