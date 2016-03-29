module DiasporaFederation
  describe Federation::Receiver do
    let(:sender_key) { OpenSSL::PKey::RSA.generate(1024) }
    let(:recipient_key) { OpenSSL::PKey::RSA.generate(1024) }

    describe ".receive_public" do
      let(:post) { FactoryGirl.build(:status_message_entity) }

      it "parses the entity with magic envelope receiver" do
        expect_callback(:fetch_public_key, post.author).and_return(sender_key)

        data = Salmon::MagicEnvelope.new(post, post.author).envelop(sender_key).to_xml

        expect_callback(:receive_entity, kind_of(Entities::StatusMessage), nil) do |_, entity|
          expect(entity.guid).to eq(post.guid)
          expect(entity.author).to eq(post.author)
          expect(entity.raw_message).to eq(post.raw_message)
          expect(entity.public).to eq("true")
        end

        described_class.receive_public(data)
      end

      it "parses the entity with legacy slap receiver" do
        expect_callback(:fetch_public_key, post.author).and_return(sender_key)

        data = DiasporaFederation::Salmon::Slap.generate_xml(post.author, sender_key, post)

        expect_callback(:receive_entity, kind_of(Entities::StatusMessage), nil) do |_, entity|
          expect(entity.guid).to eq(post.guid)
          expect(entity.author).to eq(post.author)
          expect(entity.raw_message).to eq(post.raw_message)
          expect(entity.public).to eq("true")
        end

        described_class.receive_public(data, true)
      end
    end

    describe ".receive_private" do
      let(:post) { FactoryGirl.build(:status_message_entity, public: false) }

      it "parses the entity with magic envelope receiver" do
        expect_callback(:fetch_public_key, post.author).and_return(sender_key)

        magic_env = Salmon::MagicEnvelope.new(post, post.author).envelop(sender_key)
        data = Salmon::EncryptedMagicEnvelope.encrypt(magic_env, recipient_key.public_key)

        expect_callback(:receive_entity, kind_of(Entities::StatusMessage), 1234) do |_, entity|
          expect(entity.guid).to eq(post.guid)
          expect(entity.author).to eq(post.author)
          expect(entity.raw_message).to eq(post.raw_message)
          expect(entity.public).to eq("false")
        end

        described_class.receive_private(data, recipient_key, 1234)
      end

      it "parses the entity with legacy slap receiver" do
        expect_callback(:fetch_public_key, post.author).and_return(sender_key)

        data = DiasporaFederation::Salmon::EncryptedSlap.prepare(post.author, sender_key, post)
                                                        .generate_xml(recipient_key)

        expect_callback(:receive_entity, kind_of(Entities::StatusMessage), 1234) do |_, entity|
          expect(entity.guid).to eq(post.guid)
          expect(entity.author).to eq(post.author)
          expect(entity.raw_message).to eq(post.raw_message)
          expect(entity.public).to eq("false")
        end

        described_class.receive_private(data, recipient_key, 1234, true)
      end

      it "raises when recipient private key is not available" do
        magic_env = Salmon::MagicEnvelope.new(post, post.author).envelop(sender_key)
        data = Salmon::EncryptedMagicEnvelope.encrypt(magic_env, recipient_key.public_key)

        expect {
          described_class.receive_private(data, nil, 1234)
        }.to raise_error ArgumentError, "no recipient key provided"
      end
    end
  end
end
