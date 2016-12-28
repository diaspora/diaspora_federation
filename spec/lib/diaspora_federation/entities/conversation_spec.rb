module DiasporaFederation
  describe Entities::Conversation do
    let(:parent) { FactoryGirl.create(:conversation, author: bob) }
    let(:parent_entity) { FactoryGirl.build(:related_entity, author: bob.diaspora_id) }
    let(:signed_msg1) {
      add_signatures(
        FactoryGirl.build(:message_entity, author: bob.diaspora_id, parent_guid: parent.guid, parent: parent_entity)
      )
    }
    let(:signed_msg2) {
      add_signatures(
        FactoryGirl.build(:message_entity, author: bob.diaspora_id, parent_guid: parent.guid, parent: parent_entity)
      )
    }
    let(:data) {
      FactoryGirl.attributes_for(:conversation_entity).merge!(
        messages:     [Entities::Message.new(signed_msg1), Entities::Message.new(signed_msg2)],
        author:       bob.diaspora_id,
        guid:         parent.guid,
        participants: "#{bob.diaspora_id};#{FactoryGirl.generate(:diaspora_id)}"
      )
    }

    let(:xml) { <<-XML }
<conversation>
  <diaspora_handle>#{data[:author]}</diaspora_handle>
  <guid>#{parent.guid}</guid>
  <subject>#{data[:subject]}</subject>
  <created_at>#{data[:created_at].utc.iso8601}</created_at>
  <participant_handles>#{data[:participants]}</participant_handles>
#{data[:messages].map {|a| a.to_xml.to_s.indent(2) }.join("\n")}
</conversation>
XML

    let(:string) { "Conversation:#{data[:guid]}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity", %i(parent parent_guid)

    context "default values" do
      it "allows no nested messages" do
        minimal_xml = <<-XML
<conversation>
  <author>#{data[:author]}</author>
  <guid>#{parent.guid}</guid>
  <subject>#{data[:subject]}</subject>
  <created_at>#{data[:created_at]}</created_at>
  <participant_handles>#{data[:participants]}</participant_handles>
</conversation>
XML

        parsed_instance = DiasporaFederation::Salmon::XmlPayload.unpack(Nokogiri::XML::Document.parse(minimal_xml).root)
        expect(parsed_instance.messages).to eq([])
      end
    end

    context "nested entities" do
      it "validates that nested messages have the same author" do
        invalid_data = data.merge(author: alice.diaspora_id)
        expect {
          Entities::Conversation.new(invalid_data)
        }.to raise_error Entity::ValidationError
      end
    end
  end
end
