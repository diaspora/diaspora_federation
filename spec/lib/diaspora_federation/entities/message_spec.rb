module DiasporaFederation
  describe Entities::Message do
    let(:parent) { FactoryGirl.create(:conversation, author: bob) }
    let(:parent_entity) { FactoryGirl.build(:related_entity, author: bob.diaspora_id) }
    let(:data) {
      FactoryGirl.build(:message_entity, author: alice.diaspora_id, parent_guid: parent.guid, parent: parent_entity)
                 .send(:xml_elements).merge(parent: parent_entity)
    }

    let(:xml) {
      <<-XML
<message>
  <guid>#{data[:guid]}</guid>
  <parent_guid>#{parent.guid}</parent_guid>
  <text>#{data[:text]}</text>
  <created_at>#{data[:created_at]}</created_at>
  <diaspora_handle>#{data[:author]}</diaspora_handle>
  <conversation_guid>#{data[:conversation_guid]}</conversation_guid>
  <author_signature>#{data[:author_signature]}</author_signature>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
</message>
XML
    }

    it_behaves_like "an Entity subclass", [:parent]

    it_behaves_like "an XML Entity"

    it_behaves_like "a relayable Entity"
  end
end
