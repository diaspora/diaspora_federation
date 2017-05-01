module DiasporaFederation
  describe Salmon::EncryptedSlap do
    let(:sender) { "user_test@diaspora.example.tld" }
    let(:privkey) { OpenSSL::PKey::RSA.generate(512) } # use small key for speedy specs
    let(:recipient_key) { OpenSSL::PKey::RSA.generate(1024) } # use small key for speedy specs
    let(:payload) { Entities::TestEntity.new(test: "qwertzuiop") }
    let(:slap_xml) { generate_legacy_encrypted_salmon_slap(payload, sender, privkey, recipient_key.public_key) }

    describe ".from_xml" do
      context "sanity" do
        it "accepts correct params" do
          expect_callback(:fetch_public_key, sender).and_return(privkey.public_key)

          expect {
            Salmon::EncryptedSlap.from_xml(slap_xml, recipient_key)
          }.not_to raise_error
        end

        it "raises an error when the params have a wrong type" do
          [1234, false, :symbol, payload, privkey].each do |val|
            expect {
              Salmon::EncryptedSlap.from_xml(val, val)
            }.to raise_error ArgumentError
          end
        end

        it "verifies the existence of 'encrypted_header'" do
          faulty_xml = <<XML
<diaspora xmlns="https://joindiaspora.com/protocol" xmlns:me="http://salmon-protocol.org/ns/magic-env">
</diaspora>
XML
          expect {
            Salmon::EncryptedSlap.from_xml(faulty_xml, recipient_key)
          }.to raise_error Salmon::MissingHeader
        end

        it "verifies the existence of a magic envelope" do
          faulty_xml = <<XML
<diaspora xmlns="https://joindiaspora.com/protocol" xmlns:me="http://salmon-protocol.org/ns/magic-env">
  <encrypted_header/>
</diaspora>
XML
          expect(Salmon::EncryptedSlap).to receive(:header_data).and_return(aes_key: "", iv: "", author_id: "")
          expect {
            Salmon::EncryptedSlap.from_xml(faulty_xml, recipient_key)
          }.to raise_error Salmon::MissingMagicEnvelope
        end
      end

      context "generated instance" do
        it_behaves_like "a MagicEnvelope instance" do
          subject { Salmon::EncryptedSlap.from_xml(slap_xml, recipient_key) }
        end
      end
    end
  end
end
