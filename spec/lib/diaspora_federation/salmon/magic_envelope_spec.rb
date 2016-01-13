module DiasporaFederation
  describe Salmon::MagicEnvelope do
    let(:payload) { Entities::TestEntity.new(test: "asdf") }
    let(:privkey) { OpenSSL::PKey::RSA.generate(512) } # use small key for speedy specs
    let(:envelope) { envelop_xml(Salmon::MagicEnvelope.new(privkey, payload)) }

    def envelop_xml(magic_env)
      builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.root("xmlns:me" => Salmon::MagicEnvelope::XMLNS) {
          magic_env.envelop(xml)
        }
      end
      builder.doc.at_xpath("//me:env")
    end

    def sig_subj(env)
      data = Base64.urlsafe_decode64(env.at_xpath("me:data").content)
      type = env.at_xpath("me:data")["type"]
      enc = env.at_xpath("me:encoding").content
      alg = env.at_xpath("me:alg").content

      [data, type, enc, alg].map {|i| Base64.urlsafe_encode64(i) }.join(".")
    end

    def re_sign(env, key)
      new_sig = Base64.urlsafe_encode64(key.sign(OpenSSL::Digest::SHA256.new, sig_subj(env)))
      env.at_xpath("me:sig").content = new_sig
    end

    context "sanity" do
      it "constructs an instance" do
        expect {
          Salmon::MagicEnvelope.new(privkey, payload)
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
      subject { Salmon::MagicEnvelope.new(privkey, payload) }

      it "should be an instance of Nokogiri::XML::Element" do
        expect(envelop_xml(subject)).to be_an_instance_of Nokogiri::XML::Element
      end

      it "returns a magic envelope of correct structure" do
        env = envelop_xml(subject)
        expect(env.name).to eq("env")

        control = %w(data encoding alg sig)
        env.children.each do |node|
          expect(control).to include(node.name)
          control.reject! {|i| i == node.name }
        end

        expect(control).to be_empty
      end

      it "signs the payload correctly" do
        env = envelop_xml(subject)

        subj = sig_subj(env)
        sig = Base64.urlsafe_decode64(env.at_xpath("me:sig").content)

        expect(privkey.public_key.verify(OpenSSL::Digest::SHA256.new, sig, subj)).to be_truthy
      end
    end

    describe "#encrypt!" do
      subject { Salmon::MagicEnvelope.new(privkey, payload) }

      it "encrypts the payload, returning cipher params" do
        params = subject.encrypt!
        expect(params).to include(:key, :iv)
      end

      it "actually encrypts the payload" do
        plain_payload = subject.payload
        params = subject.encrypt!
        encrypted_payload = subject.payload

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
        it "works with sane input" do
          expect {
            Salmon::MagicEnvelope.unenvelop(envelope, privkey.public_key)
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
            Salmon::MagicEnvelope.unenvelop(envelope, other_key.public_key)
          }.to raise_error Salmon::InvalidSignature
        end

        it "verifies the encoding" do
          bad_env = envelop_xml(Salmon::MagicEnvelope.new(privkey, payload))
          elem = bad_env.at_xpath("me:encoding")
          elem.content = "invalid_enc"
          re_sign(bad_env, privkey)
          expect {
            Salmon::MagicEnvelope.unenvelop(bad_env, privkey.public_key)
          }.to raise_error Salmon::InvalidEncoding
        end

        it "verifies the algorithm" do
          bad_env = envelop_xml(Salmon::MagicEnvelope.new(privkey, payload))
          elem = bad_env.at_xpath("me:alg")
          elem.content = "invalid_alg"
          re_sign(bad_env, privkey)
          expect {
            Salmon::MagicEnvelope.unenvelop(bad_env, privkey.public_key)
          }.to raise_error Salmon::InvalidAlgorithm
        end
      end

      it "returns the original entity" do
        entity = Salmon::MagicEnvelope.unenvelop(envelope, privkey.public_key)
        expect(entity).to be_an_instance_of Entities::TestEntity
        expect(entity.test).to eq("asdf")
      end

      it "decrypts on the fly, when cipher params are present" do
        env = Salmon::MagicEnvelope.new(privkey, payload)
        params = env.encrypt!

        envelope = envelop_xml(env)

        entity = Salmon::MagicEnvelope.unenvelop(envelope, privkey.public_key, params)
        expect(entity).to be_an_instance_of Entities::TestEntity
        expect(entity.test).to eq("asdf")
      end
    end
  end
end
