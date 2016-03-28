module DiasporaFederation
  describe Entities::Comment do
    let(:parent) { FactoryGirl.create(:post, author: bob) }
    let(:parent_entity) { FactoryGirl.build(:related_entity, author: bob.diaspora_id) }
    let(:data) {
      FactoryGirl.build(:comment_entity, author: alice.diaspora_id, parent_guid: parent.guid, parent: parent_entity)
                 .send(:xml_elements).merge(created_at: Time.now.utc, parent: parent_entity)
    }

    let(:xml) {
      <<-XML
<comment>
  <guid>#{data[:guid]}</guid>
  <parent_guid>#{parent.guid}</parent_guid>
  <text>#{data[:text]}</text>
  <diaspora_handle>#{data[:author]}</diaspora_handle>
  <author_signature>#{data[:author_signature]}</author_signature>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
</comment>
XML
    }

    it_behaves_like "an Entity subclass", [:parent]

    it_behaves_like "an XML Entity", [:created_at]

    it_behaves_like "a relayable Entity"

    describe "#created_at" do
      it "has a created_at after parse" do
        entity = described_class.from_xml(Nokogiri::XML::Document.parse(xml).root)
        expect(entity.created_at).to be_within(1.second).of(Time.now.utc)
      end

      it "parses the created_at from the xml if it is included and correctly signed" do
        created_at = Time.now.utc - 1.minute
        comment_data = FactoryGirl.build(:comment_entity, author: alice.diaspora_id, parent_guid: parent.guid).to_h
        comment_data[:created_at] = created_at
        comment_data[:parent] = parent_entity
        comment = described_class.new(comment_data, %i(author guid parent_guid text created_at))

        parsed_comment = described_class.from_xml(comment.to_xml)
        expect(parsed_comment.created_at).to eq(created_at.to_s)
      end
    end

    describe "#parent_type" do
      it "returns \"Post\" as parent type" do
        expect(described_class.new(data).parent_type).to eq("Post")
      end
    end
  end
end
