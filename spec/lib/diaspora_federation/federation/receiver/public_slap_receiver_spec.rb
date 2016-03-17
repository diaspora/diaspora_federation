module DiasporaFederation
  describe Federation::Receiver::PublicSlapReceiver do
    let(:sender_id) { FactoryGirl.generate(:diaspora_id) }
    let(:sender_key) { OpenSSL::PKey::RSA.generate(1024) }
    let(:entity) { FactoryGirl.build(:status_message_entity) }
    let(:xml) { DiasporaFederation::Salmon::Slap.generate_xml(sender_id, sender_key, entity) }

    it "parses the entity if everything is fine" do
      expect(DiasporaFederation.callbacks).to receive(:trigger).with(
        :fetch_public_key_by_diaspora_id, sender_id
      ).and_return(sender_key)

      parsed_entity = described_class.new(xml).parse
      expect(parsed_entity).to be_a(Entities::StatusMessage)
      expect(parsed_entity.guid).to eq(entity.guid)
      expect(parsed_entity.public).to eq("true")
    end

    it "raises when sender public key is not available" do
      expect(DiasporaFederation.callbacks).to receive(:trigger).with(
        :fetch_public_key_by_diaspora_id, sender_id
      ).and_return(nil)

      expect {
        described_class.new(xml).parse
      }.to raise_error Salmon::SenderKeyNotFound
    end

    it "raises when bad xml was supplied" do
      expect {
        described_class.new("<XML/>").parse
      }.to raise_error Salmon::MissingAuthor
    end
  end
end
