module DiasporaFederation
  describe Salmon::MagicEnvelope do
    let(:sender) { FactoryGirl.generate(:diaspora_id) }
    let(:privkey) { OpenSSL::PKey::RSA.generate(512) } # use small key for speedy specs
    let(:payload) { Entities::TestEntity.new(test: "asdf") }
    let(:envelope) { Salmon::MagicEnvelope.new(payload, sender) }

    def sig_subj(env)
      data = Base64.urlsafe_decode64(env.at_xpath("me:data").content)
      type = env.at_xpath("me:data")["type"]
      enc = env.at_xpath("me:encoding").content
      alg = env.at_xpath("me:alg").content

      [data, type, enc, alg].map {|i| Base64.urlsafe_encode64(i) }.join(".")
    end

    context "sanity" do
      it "constructs an instance" do
        expect {
          Salmon::MagicEnvelope.new(payload, sender)
        }.not_to raise_error
      end

      it "raises an error if the param types are wrong" do
        ["asdf", 1234, :test, false].each do |val|
          expect {
            Salmon::MagicEnvelope.new(val, val)
          }.to raise_error ArgumentError
        end
      end
    end

    describe "#envelop" do
      context "sanity" do
        it "raises an error if the param types are wrong" do
          ["asdf", 1234, :test, false].each do |val|
            expect {
              envelope.envelop(val)
            }.to raise_error ArgumentError
          end
        end
      end

      it "should be an instance of Nokogiri::XML::Element" do
        expect(envelope.envelop(privkey)).to be_an_instance_of Nokogiri::XML::Element
      end

      it "returns a magic envelope of correct structure" do
        env_xml = envelope.envelop(privkey)
        expect(env_xml.name).to eq("env")

        control = %w(data encoding alg sig)
        env_xml.children.each do |node|
          expect(control).to include(node.name)
          control.reject! {|i| i == node.name }
        end

        expect(control).to be_empty
      end

      it "adds the sender to the signature" do
        key_id = envelope.envelop(privkey).at_xpath("me:sig")["key_id"]

        expect(Base64.urlsafe_decode64(key_id)).to eq(sender)
      end

      it "adds the data_type" do
        data_type = envelope.envelop(privkey).at_xpath("me:data")["type"]

        expect(data_type).to eq("application/xml")
      end

      it "signs the payload correctly" do
        env_xml = envelope.envelop(privkey)

        subj = sig_subj(env_xml)
        sig = Base64.urlsafe_decode64(env_xml.at_xpath("me:sig").content)

        expect(privkey.public_key.verify(OpenSSL::Digest::SHA256.new, sig, subj)).to be_truthy
      end
    end

    describe "#encrypt!" do
      it "encrypts the payload, returning cipher params" do
        params = envelope.encrypt!
        expect(params).to include(:key, :iv)
      end

      it "actually encrypts the payload" do
        plain_payload = envelope.send(:payload_data)
        params = envelope.encrypt!
        encrypted_payload = envelope.send(:payload_data)

        cipher = OpenSSL::Cipher.new(Salmon::AES::CIPHER)
        cipher.encrypt
        cipher.iv = params[:iv]
        cipher.key = params[:key]

        ciphertext = cipher.update(plain_payload) + cipher.final

        expect(Base64.strict_encode64(ciphertext)).to eq(encrypted_payload)
      end
    end

    describe ".unenvelop" do
      context "sanity" do
        def re_sign(env, key)
          new_sig = Base64.urlsafe_encode64(key.sign(OpenSSL::Digest::SHA256.new, sig_subj(env)))
          env.at_xpath("me:sig").content = new_sig
        end

        it "works with sane input" do
          expect {
            Salmon::MagicEnvelope.unenvelop(envelope.envelop(privkey), privkey.public_key)
          }.not_to raise_error
        end

        it "raises an error if the param types are wrong" do
          ["asdf", 1234, :test, false].each do |val|
            expect {
              Salmon::MagicEnvelope.unenvelop(val, val)
            }.to raise_error ArgumentError
          end
        end

        it "verifies the envelope structure" do
          expect {
            Salmon::MagicEnvelope.unenvelop(Nokogiri::XML::Document.parse("<asdf/>").root, privkey.public_key)
          }.to raise_error Salmon::InvalidEnvelope
        end

        it "verifies the signature" do
          other_key = OpenSSL::PKey::RSA.generate(512)
          expect {
            Salmon::MagicEnvelope.unenvelop(envelope.envelop(privkey), other_key.public_key)
          }.to raise_error Salmon::InvalidSignature
        end

        it "verifies the encoding" do
          bad_env = envelope.envelop(privkey)
          bad_env.at_xpath("me:encoding").content = "invalid_enc"
          re_sign(bad_env, privkey)
          expect {
            Salmon::MagicEnvelope.unenvelop(bad_env, privkey.public_key)
          }.to raise_error Salmon::InvalidEncoding
        end

        it "verifies the algorithm" do
          bad_env = envelope.envelop(privkey)
          bad_env.at_xpath("me:alg").content = "invalid_alg"
          re_sign(bad_env, privkey)
          expect {
            Salmon::MagicEnvelope.unenvelop(bad_env, privkey.public_key)
          }.to raise_error Salmon::InvalidAlgorithm
        end
      end

      it "returns the original entity" do
        entity = Salmon::MagicEnvelope.unenvelop(envelope.envelop(privkey), privkey.public_key)
        expect(entity).to be_an_instance_of Entities::TestEntity
        expect(entity.test).to eq("asdf")
      end

      it "decrypts on the fly, when cipher params are present" do
        params = envelope.encrypt!

        env_xml = envelope.envelop(privkey)

        entity = Salmon::MagicEnvelope.unenvelop(env_xml, privkey.public_key, params)
        expect(entity).to be_an_instance_of Entities::TestEntity
        expect(entity.test).to eq("asdf")
      end

      context "use key_id from magic envelope" do
        it "returns the original entity" do
          expect(DiasporaFederation.callbacks).to receive(:trigger).with(
            :fetch_public_key_by_diaspora_id, sender
          ).and_return(privkey.public_key)

          entity = Salmon::MagicEnvelope.unenvelop(envelope.envelop(privkey))
          expect(entity).to be_an_instance_of Entities::TestEntity
          expect(entity.test).to eq("asdf")
        end

        it "raises if the magic envelope has no key_id" do
          bad_env = envelope.envelop(privkey)

          bad_env.at_xpath("me:sig").attributes["key_id"].remove

          expect {
            Salmon::MagicEnvelope.unenvelop(bad_env)
          }.to raise_error Salmon::InvalidEnvelope
        end

        it "raises if the sender key is not found" do
          expect(DiasporaFederation.callbacks).to receive(:trigger).with(
            :fetch_public_key_by_diaspora_id, sender
          ).and_return(nil)

          expect {
            Salmon::MagicEnvelope.unenvelop(envelope.envelop(privkey))
          }.to raise_error Salmon::SenderKeyNotFound
        end
      end
    end
  end
end
