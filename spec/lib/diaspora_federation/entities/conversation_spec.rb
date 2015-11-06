module DiasporaFederation
  describe Entities::Conversation do
    let(:msg1) { FactoryGirl.build(:message_entity) }
    let(:msg2) { FactoryGirl.build(:message_entity) }
    let(:data) {
      FactoryGirl.attributes_for(:conversation_entity).merge!(
        messages:        [msg1, msg2],
        participant_ids: "#{FactoryGirl.generate(:diaspora_id)};#{FactoryGirl.generate(:diaspora_id)}"
      )
    }

    let(:xml) {
      <<-XML
<conversation>
  <guid>#{data[:guid]}</guid>
  <subject>#{data[:subject]}</subject>
  <created_at>#{data[:created_at]}</created_at>
  <message>
    <guid>#{msg1.guid}</guid>
    <parent_guid>#{msg1.parent_guid}</parent_guid>
    <parent_author_signature>#{msg1.parent_author_signature}</parent_author_signature>
    <author_signature>#{msg1.author_signature}</author_signature>
    <text>#{msg1.text}</text>
    <created_at>#{msg1.created_at}</created_at>
    <diaspora_handle>#{msg1.diaspora_id}</diaspora_handle>
    <conversation_guid>#{msg1.conversation_guid}</conversation_guid>
  </message>
  <message>
    <guid>#{msg2.guid}</guid>
    <parent_guid>#{msg2.parent_guid}</parent_guid>
    <parent_author_signature>#{msg2.parent_author_signature}</parent_author_signature>
    <author_signature>#{msg2.author_signature}</author_signature>
    <text>#{msg2.text}</text>
    <created_at>#{msg2.created_at}</created_at>
    <diaspora_handle>#{msg2.diaspora_id}</diaspora_handle>
    <conversation_guid>#{msg2.conversation_guid}</conversation_guid>
  </message>
  <diaspora_handle>#{data[:diaspora_id]}</diaspora_handle>
  <participant_handles>#{data[:participant_ids]}</participant_handles>
</conversation>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
