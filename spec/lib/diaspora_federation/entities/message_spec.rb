module DiasporaFederation
  describe Entities::Message do
    let(:data) { Test.relayable_attributes_with_signatures(:message_entity) }

    let(:xml) {
      <<-XML
<message>
  <guid>#{data[:guid]}</guid>
  <parent_guid>#{data[:parent_guid]}</parent_guid>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
  <author_signature>#{data[:author_signature]}</author_signature>
  <text>#{data[:text]}</text>
  <created_at>#{data[:created_at]}</created_at>
  <diaspora_handle>#{data[:diaspora_id]}</diaspora_handle>
  <conversation_guid>#{data[:conversation_guid]}</conversation_guid>
</message>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a relayable Entity"

    describe ".get_target_entity_type" do
      it "returns \"Conversation\" as target type" do
        expect(described_class.get_target_entity_type(data)).to eq("Conversation")
      end
    end
  end
end
