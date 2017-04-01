module DiasporaFederation
  describe Entities::Comment do
    let(:parent) { FactoryGirl.create(:post, author: bob) }
    let(:parent_entity) { FactoryGirl.build(:related_entity, author: bob.diaspora_id) }
    let(:data) {
      FactoryGirl
        .attributes_for(
          :comment_entity,
          author:      alice.diaspora_id,
          parent_guid: parent.guid,
          parent:      parent_entity,
          created_at:  Time.now.utc
        ).tap {|hash| add_signatures(hash) }
    }

    let(:xml) { <<-XML }
<comment>
  <guid>#{data[:guid]}</guid>
  <parent_guid>#{parent.guid}</parent_guid>
  <text>#{data[:text]}</text>
  <diaspora_handle>#{data[:author]}</diaspora_handle>
  <author_signature>#{data[:author_signature]}</author_signature>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
</comment>
XML

    let(:json) { <<-JSON }
{
  "entity_type": "comment",
  "entity_data": {
    "author": "#{data[:author]}",
    "guid": "#{data[:guid]}",
    "parent_guid": "#{parent.guid}",
    "author_signature": "#{data[:author_signature]}",
    "parent_author_signature": "#{data[:parent_author_signature]}",
    "text": "#{data[:text]}",
    "created_at": "#{data[:created_at].iso8601}"
  },
  "property_order": [
    "guid",
    "parent_guid",
    "text",
    "author"
  ]
}
JSON

    let(:string) { "Comment:#{data[:guid]}:#{parent.guid}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity", [:created_at]

    it_behaves_like "a JSON Entity"

    it_behaves_like "a relayable Entity"

    it_behaves_like "a relayable JSON entity"

    describe "#created_at" do
      it "has a created_at after parse" do
        entity = described_class.from_xml(Nokogiri::XML::Document.parse(xml).root)
        expect(entity.created_at).to be_within(1.second).of(Time.now.utc)
      end

      it "parses the created_at from the xml if it is included and correctly signed" do
        created_at = Time.now.utc.change(usec: 0) - 1.minute
        comment_data = FactoryGirl.attributes_for(:comment_entity, author: alice.diaspora_id, parent_guid: parent.guid)
        comment_data[:created_at] = created_at
        comment_data[:parent] = parent_entity
        comment = described_class.new(comment_data, %i(author guid parent_guid text created_at))

        parsed_comment = described_class.from_xml(comment.to_xml)
        expect(parsed_comment.created_at).to eq(created_at)
      end
    end
  end
end
