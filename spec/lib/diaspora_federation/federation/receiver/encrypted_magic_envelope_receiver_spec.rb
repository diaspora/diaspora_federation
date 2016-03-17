module DiasporaFederation
  describe Federation::Receiver::EncryptedMagicEnvelopeReceiver do
    let(:sender_id) { FactoryGirl.generate(:diaspora_id) }
    let(:sender_key) { OpenSSL::PKey::RSA.generate(1024) }
    let(:recipient_key) { OpenSSL::PKey::RSA.generate(1024) }
    let(:entity) { FactoryGirl.build(:status_message_entity, public: false) }
    let(:magic_env) { Salmon::MagicEnvelope.new(entity).envelop(sender_key, sender_id) }
    let(:data) { Salmon::EncryptedMagicEnvelope.encrypt(magic_env, recipient_key.public_key) }

    it "parses the entity if everything is fine" do
      expect(DiasporaFederation.callbacks).to receive(:trigger).with(
        :fetch_public_key_by_diaspora_id, sender_id
      ).and_return(sender_key)

      parsed_entity = described_class.new(data, recipient_key).parse
      expect(parsed_entity).to be_a(Entities::StatusMessage)
      expect(parsed_entity.guid).to eq(entity.guid)
      expect(parsed_entity.public).to eq("false")
    end
  end
end
