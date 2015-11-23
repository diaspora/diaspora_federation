module DiasporaFederation
  describe Entities::Conversation do
    let(:msg1_data) { Test.relayable_attributes_with_signatures(:message_entity) }
    let(:msg2_data) { Test.relayable_attributes_with_signatures(:message_entity) }
    let(:msg1) { FactoryGirl.build(:message_entity, msg1_data) }
    let(:msg2) { FactoryGirl.build(:message_entity, msg2_data) }
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
