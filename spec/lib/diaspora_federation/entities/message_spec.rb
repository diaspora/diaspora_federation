module DiasporaFederation
  describe Entities::Message do
    let(:data) { Fabricate.attributes_for(:message_entity, author: alice.diaspora_id) }

    let(:xml) { <<-XML }
<message>
  <author>#{data[:author]}</author>
  <guid>#{data[:guid]}</guid>
  <text>#{data[:text]}</text>
  <created_at>#{data[:created_at].utc.iso8601}</created_at>
  <conversation_guid>#{data[:conversation_guid]}</conversation_guid>
</message>
XML

    let(:string) { "Message:#{data[:guid]}:#{data[:conversation_guid]}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
