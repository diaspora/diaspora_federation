module DiasporaFederation
  describe Federation::Receiver::Public do
    let(:sender_id) { FactoryGirl.generate(:diaspora_id) }
    let(:sender_key) { OpenSSL::PKey::RSA.generate(1024) }
    let(:xml) {
      DiasporaFederation::Salmon::Slap.generate_xml(
        sender_id,
        sender_key,
        FactoryGirl.build(:request_entity)
      )
    }

    it "calls save_entity_after_receive if everything is fine" do
      expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                .with(:fetch_public_key_by_diaspora_id, sender_id)
                                                .and_return(sender_key)
      expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                .with(:save_entity_after_receive, kind_of(Entity))

      described_class.new(xml).receive!
    end

    it "raises when sender public key is not available" do
      expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                .with(:fetch_public_key_by_diaspora_id, sender_id)
                                                .and_return(nil)

      expect {
        described_class.new(xml).receive!
      }.to raise_error Federation::SenderKeyNotFound
    end

    it "raises when bad xml was supplied" do
      expect {
        described_class.new("<XML/>").receive!
      }.to raise_error Salmon::MissingAuthor
    end
  end
end
