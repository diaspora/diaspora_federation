module DiasporaFederation
  describe Federation::Receiver::Private do
    let(:recipient) { 42 }
    let(:entity) { FactoryGirl.build(:status_message_entity, public: false) }
    let(:magic_env) { Salmon::MagicEnvelope.new(entity, entity.author) }

    describe "#receive" do
      it "receives a private post" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(:receive_entity, entity, recipient)

        described_class.new(magic_env, recipient).receive
      end

      it "validates the sender" do
        sender = FactoryGirl.generate(:diaspora_id)
        bad_env = Salmon::MagicEnvelope.new(entity, sender)

        expect {
          described_class.new(bad_env, recipient).receive
        }.to raise_error Federation::Receiver::InvalidSender
      end

      it "validates the recipient" do
        expect {
          described_class.new(magic_env).receive
        }.to raise_error Federation::Receiver::RecipientRequired
      end
    end
  end
end
