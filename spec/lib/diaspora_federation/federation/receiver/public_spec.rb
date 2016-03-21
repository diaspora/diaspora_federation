module DiasporaFederation
  describe Federation::Receiver::Public do
    let(:entity) { FactoryGirl.build(:status_message_entity) }
    let(:magic_env) { Salmon::MagicEnvelope.new(entity, entity.author) }

    describe "#receive" do
      it "receives a public post" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(:receive_entity, entity, nil)

        described_class.new(magic_env).receive
      end

      it "validates the sender" do
        sender = FactoryGirl.generate(:diaspora_id)
        bad_env = Salmon::MagicEnvelope.new(entity, sender)

        expect {
          described_class.new(bad_env).receive
        }.to raise_error Federation::Receiver::InvalidSender
      end
    end
  end
end
