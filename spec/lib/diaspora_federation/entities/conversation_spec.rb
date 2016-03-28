module DiasporaFederation
  describe Entities::Conversation do
    let(:parent) { FactoryGirl.create(:conversation, author: bob) }
    let(:parent_entity) { FactoryGirl.build(:related_entity, author: bob.diaspora_id) }
    let(:signed_msg1) {
      msg = FactoryGirl.build(:message_entity, author: alice.diaspora_id, parent_guid: parent.guid).send(:xml_elements)
      Entities::Message.new(msg.merge(parent: parent_entity))
    }
    let(:signed_msg2) {
      msg = FactoryGirl.build(:message_entity, author: alice.diaspora_id, parent_guid: parent.guid).send(:xml_elements)
      Entities::Message.new(msg.merge(parent: parent_entity))
    }
    let(:data) {
      FactoryGirl.attributes_for(:conversation_entity).merge!(
        messages:     [signed_msg1, signed_msg2],
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
