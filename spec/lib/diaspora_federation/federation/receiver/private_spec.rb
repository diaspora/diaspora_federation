module DiasporaFederation
  describe Federation::Receiver::Private do
    let(:sender_id) { FactoryGirl.generate(:diaspora_id) }
    let(:sender_key) { OpenSSL::PKey::RSA.generate(1024) }
    let(:recipient_key) { OpenSSL::PKey::RSA.generate(1024) }
    let(:xml) {
      DiasporaFederation::Salmon::EncryptedSlap.prepare(sender_id, sender_key, FactoryGirl.build(:request_entity))
        .generate_xml(recipient_key)
    }

    it "calls save_entity_after_receive if everything is fine" do
      expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                .with(:fetch_public_key_by_diaspora_id, sender_id)
                                                .and_return(sender_key)

      expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                .with(:save_entity_after_receive, kind_of(Entity))

      described_class.new(xml, recipient_key).receive!
    end

    it "raises when sender public key is not available" do
      expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                .with(:fetch_public_key_by_diaspora_id, sender_id)
                                                .and_return(nil)

      expect {
        described_class.new(xml, recipient_key).receive!
      }.to raise_error Federation::SenderKeyNotFound
    end

    it "raises when recipient private key is not available" do
      expect {
        described_class.new(xml, nil).receive!
      }.to raise_error Federation::RecipientKeyNotFound
    end

    it "raises when bad xml was supplied" do
      expect {
        described_class.new("<XML/>", recipient_key).receive!
      }.to raise_error Salmon::MissingHeader
    end
  end
end
