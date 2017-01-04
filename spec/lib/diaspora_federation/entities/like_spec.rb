module DiasporaFederation
  describe Entities::Like do
    let(:parent) { FactoryGirl.create(:post, author: bob) }
    let(:parent_entity) { FactoryGirl.build(:related_entity, author: bob.diaspora_id) }
    let(:data) {
      FactoryGirl.attributes_for(
        :like_entity,
        author:      alice.diaspora_id,
        parent_guid: parent.guid,
        parent_type: parent.entity_type,
        parent:      parent_entity
      ).tap {|hash| add_signatures(hash) }
    }

    let(:xml) { <<-XML }
<like>
  <positive>#{data[:positive]}</positive>
  <guid>#{data[:guid]}</guid>
  <target_type>#{parent.entity_type}</target_type>
  <parent_guid>#{parent.guid}</parent_guid>
  <diaspora_handle>#{data[:author]}</diaspora_handle>
  <author_signature>#{data[:author_signature]}</author_signature>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
</like>
XML

    let(:string) { "Like:#{data[:guid]}:Post:#{parent.guid}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a relayable Entity"

    context "invalid XML" do
      it "raises a ValidationError if the parent_type is missing" do
        broken_xml = <<-XML
<like>
  <parent_guid>#{parent.guid}</parent_guid>
  <author_signature>#{data[:author_signature]}</author_signature>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
</like>
XML

        expect {
          DiasporaFederation::Entities::Like.from_xml(Nokogiri::XML::Document.parse(broken_xml).root)
        }.to raise_error Entity::ValidationError, "invalid DiasporaFederation::Entities::Like! missing 'parent_type'."
      end

      it "raises a ValidationError if the parent_guid is missing" do
        broken_xml = <<-XML
<like>
  <target_type>#{parent.entity_type}</target_type>
  <author_signature>#{data[:author_signature]}</author_signature>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
</like>
XML

        expect {
          DiasporaFederation::Entities::Like.from_xml(Nokogiri::XML::Document.parse(broken_xml).root)
        }.to raise_error Entity::ValidationError, "invalid DiasporaFederation::Entities::Like! missing 'parent_guid'."
      end
    end
  end
end
