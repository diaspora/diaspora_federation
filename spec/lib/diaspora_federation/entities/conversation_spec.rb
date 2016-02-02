module DiasporaFederation
  describe Entities::Conversation do
    let(:parent) { FactoryGirl.create(:conversation, author: bob) }
    let(:msg1) { FactoryGirl.build(:message_entity, diaspora_id: alice.diaspora_id, parent_guid: parent.guid).to_h }
    let(:msg2) { FactoryGirl.build(:message_entity, diaspora_id: alice.diaspora_id, parent_guid: parent.guid).to_h }
    let(:signed_msg1) { Entities::Message.new(msg1) }
    let(:signed_msg2) { Entities::Message.new(msg2) }
    let(:data) {
      FactoryGirl.attributes_for(:conversation_entity).merge!(
        messages:        [signed_msg1, signed_msg2],
        diaspora_id:     bob.diaspora_id,
        guid:            parent.guid,
        participant_ids: "#{bob.diaspora_id};#{FactoryGirl.generate(:diaspora_id)}"
      )
    }

    let(:xml) {
      <<-XML
<conversation>
  <guid>#{parent.guid}</guid>
  <subject>#{data[:subject]}</subject>
  <created_at>#{data[:created_at]}</created_at>
#{data[:messages].map {|a| a.to_xml.to_s.indent(2) }.join("\n")}
  <diaspora_handle>#{data[:diaspora_id]}</diaspora_handle>
  <participant_handles>#{data[:participant_ids]}</participant_handles>
</conversation>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
