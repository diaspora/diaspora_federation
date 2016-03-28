module DiasporaFederation
  describe Entities::Conversation do
    let(:parent) { FactoryGirl.create(:conversation, author: bob) }
    let(:parent_entity) { FactoryGirl.build(:related_entity, author: bob.diaspora_id) }
    let(:signed_msg1) {
      FactoryGirl.build(:message_entity, author: alice.diaspora_id, parent_guid: parent.guid, parent: parent_entity)
                 .send(:xml_elements).merge(parent: parent_entity)
    }
    let(:signed_msg2) {
      FactoryGirl.build(:message_entity, author: alice.diaspora_id, parent_guid: parent.guid, parent: parent_entity)
                 .send(:xml_elements).merge(parent: parent_entity)
    }
    let(:data) {
      FactoryGirl.attributes_for(:conversation_entity).merge!(
        messages:     [Entities::Message.new(signed_msg1), Entities::Message.new(signed_msg2)],
        author:       bob.diaspora_id,
        guid:         parent.guid,
        participants: "#{bob.diaspora_id};#{FactoryGirl.generate(:diaspora_id)}"
      )
    }

    let(:xml) {
      <<-XML
<conversation>
  <guid>#{parent.guid}</guid>
  <subject>#{data[:subject]}</subject>
  <created_at>#{data[:created_at]}</created_at>
#{data[:messages].map {|a| a.to_xml.to_s.indent(2) }.join("\n")}
  <diaspora_handle>#{data[:author]}</diaspora_handle>
  <participant_handles>#{data[:participants]}</participant_handles>
</conversation>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
