module DiasporaFederation
  describe Entities::Message do
    let(:parent) { FactoryGirl.create(:conversation, author: bob) }
    let(:data) { FactoryGirl.build(:message_entity, author: alice.diaspora_id, parent_guid: parent.guid).to_signed_h }

    let(:xml) {
      <<-XML
<message>
  <diaspora_handle>#{data[:author]}</diaspora_handle>
  <guid>#{data[:guid]}</guid>
  <parent_guid>#{parent.guid}</parent_guid>
  <author_signature>#{data[:author_signature]}</author_signature>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
  <text>#{data[:text]}</text>
  <created_at>#{data[:created_at]}</created_at>
  <conversation_guid>#{data[:conversation_guid]}</conversation_guid>
</message>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a relayable Entity"

    describe "#parent_type" do
      it "returns \"Conversation\" as parent type" do
        expect(described_class.new(data).parent_type).to eq("Conversation")
      end
    end
  end
end
