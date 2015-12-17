module DiasporaFederation
  describe Receiver::Private do
    let(:sender_id) { FactoryGirl.generate(:diaspora_id) }
    let(:sender_key) { OpenSSL::PKey::RSA.generate(1024) }
    let(:recipient_key) { OpenSSL::PKey::RSA.generate(1024) }
    let(:recipient_guid) { FactoryGirl.generate(:guid) }
    let(:xml) {
      DiasporaFederation::Salmon::EncryptedSlap.generate_xml(
        sender_id,
        sender_key,
        FactoryGirl.build(:request_entity),
        recipient_key
      )
    }

    it "calls entity_persist if everyting is fine" do
      expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                .with(:fetch_public_key_by_diaspora_id, sender_id)
                                                .and_return(sender_key)
      expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                .with(:fetch_private_key_by_user_guid, recipient_guid)
                                                .and_return(recipient_key)

      expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                .with(:entity_persist, kind_of(Entity), recipient_guid, sender_id)

      described_class.new(recipient_guid, xml).receive!
    end

    it "raises when sender public key is not available" do
      expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                .with(:fetch_public_key_by_diaspora_id, sender_id)
                                                .and_return(nil)
      expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                .with(:fetch_private_key_by_user_guid, recipient_guid)
                                                .and_return(recipient_key)

      expect { described_class.new(recipient_guid, xml).receive! }.to raise_error SenderNotFound
    end

    it "raises when recipient private key is not available" do
      expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                .with(:fetch_private_key_by_user_guid, recipient_guid)
                                                .and_return(nil)

      expect { described_class.new(recipient_guid, xml).receive! }.to raise_error RecipientNotFound
    end

    it "raises when bad xml was supplied" do
      expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                .with(:fetch_private_key_by_user_guid, recipient_guid)
                                                .and_return(recipient_key)

      expect { described_class.new(recipient_guid, "<XML/>").receive! }.to raise_error Salmon::MissingHeader
    end
  end
end
