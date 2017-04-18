module DiasporaFederation
  describe Entities::Message do
    let(:parent) { Fabricate(:conversation, author: bob) }
    let(:parent_entity) { Fabricate(:related_entity, author: bob.diaspora_id) }
    let(:data) {
      Fabricate
        .attributes_for(:message_entity, author: alice.diaspora_id, parent_guid: parent.guid, parent: parent_entity)
        .tap {|hash| add_signatures(hash) }
    }

    let(:xml) { <<-XML }
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

    let(:string) { "Message:#{data[:guid]}:#{parent.guid}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity", %i(parent parent_guid)

    it_behaves_like "a relayable Entity"

    describe "#sender_valid?" do
      let(:entity) { Entities::Message.new(data) }

      it "allows the author" do
        expect(entity.sender_valid?(alice.diaspora_id)).to be_truthy
      end

      it "allows parent author if the signature is valid" do
        expect_callback(:fetch_related_entity, "Conversation", entity.conversation_guid).and_return(parent_entity)
        expect_callback(:fetch_public_key, alice.diaspora_id).and_return(alice.private_key)
        expect(entity.sender_valid?(bob.diaspora_id)).to be_truthy
      end

      it "does not allow any other person" do
        expect_callback(:fetch_related_entity, "Conversation", entity.conversation_guid).and_return(parent_entity)
        invalid_sender = Fabricate.sequence(:diaspora_id)
        expect(entity.sender_valid?(invalid_sender)).to be_falsey
      end

      it "does not allow the parent author if the signature is invalid" do
        expect_callback(:fetch_related_entity, "Conversation", entity.conversation_guid).and_return(parent_entity)
        expect_callback(:fetch_public_key, alice.diaspora_id).and_return(alice.private_key)
        invalid_msg = Entities::Message.new(data.merge(author_signature: "aa"))
        expect {
          invalid_msg.sender_valid?(bob.diaspora_id)
        }.to raise_error Entities::Relayable::SignatureVerificationFailed, "wrong author_signature for #{invalid_msg}"
      end

      it "raises NotFetchable if the parent Conversation can not be found" do
        expect_callback(:fetch_related_entity, "Conversation", entity.conversation_guid).and_return(nil)
        expect {
          entity.sender_valid?(bob.diaspora_id)
        }.to raise_error Federation::Fetcher::NotFetchable
      end
    end

    context "relayable signature verification" do
      it "does not verify the signature" do
        data.merge!(author_signature: "aa", parent_author_signature: "bb")
        xml = Entities::Message.new(data).to_xml

        expect {
          Entities::Message.from_xml(xml)
        }.not_to raise_error
      end
    end

    describe ".from_xml" do
      it "adds a nil parent" do
        xml = Entities::Message.new(data).to_xml
        parsed = Entities::Message.from_xml(xml)
        expect(parsed.parent).to be_nil
      end

      it "uses the parent_guid from the parsed xml" do
        xml = Entities::Message.new(data).to_xml
        parsed = Entities::Message.from_xml(xml)
        expect(parsed.parent_guid).to eq(data[:parent_guid])
      end

      it "uses nil for parent_guid if not in the xml" do
        xml = <<-XML
<message>
  <author>#{data[:author]}</author>
  <guid>#{data[:guid]}</guid>
  <text>#{data[:text]}</text>
  <created_at>#{data[:created_at]}</created_at>
  <conversation_guid>#{data[:conversation_guid]}</conversation_guid>
</message>
XML

        parsed = Entities::Message.from_xml(Nokogiri::XML::Document.parse(xml).root)
        expect(parsed.parent_guid).to be_nil
      end
    end
  end
end
