module DiasporaFederation
  describe Salmon::EncryptedSlap do
    let(:sender) { "user_test@diaspora.example.tld" }
    let(:privkey) { OpenSSL::PKey::RSA.generate(512) } # use small key for speedy specs
    let(:recipient_key) { OpenSSL::PKey::RSA.generate(1024) } # use small key for speedy specs
    let(:payload) { Entities::TestEntity.new(test: "qwertzuiop") }
    let(:slap_xml) { Salmon::EncryptedSlap.prepare(sender, privkey, payload).generate_xml(recipient_key.public_key) }

    context "generate" do
      describe ".prepare" do
        context "sanity" do
          it "raises an error when the sender is the wrong type" do
            [1234, true, :symbol, payload, privkey].each do |val|
              expect {
                Salmon::EncryptedSlap.prepare(val, privkey, payload)
              }.to raise_error ArgumentError
            end
          end

          it "raises an error when the privkey is the wrong type" do
            ["asdf", 1234, true, :symbol, payload].each do |val|
              expect {
                Salmon::EncryptedSlap.prepare(sender, val, payload)
              }.to raise_error ArgumentError
            end
          end

          it "raises an error when the entity is the wrong type" do
            ["asdf", 1234, true, :symbol, privkey].each do |val|
              expect {
                Salmon::EncryptedSlap.prepare(sender, privkey, val)
              }.to raise_error ArgumentError
            end
          end
        end
      end

      describe ".generate_xml" do
        let(:ns) { {d: Salmon::XMLNS, me: Salmon::MagicEnvelope::XMLNS} }

        context "sanity" do
          it "accepts correct params" do
            expect {
              Salmon::EncryptedSlap.prepare(sender, privkey, payload).generate_xml(recipient_key.public_key)
            }.not_to raise_error
          end

          it "raises an error when the params are the wrong type" do
            ["asdf", 1234, true, :symbol, payload].each do |val|
              expect {
                Salmon::EncryptedSlap.prepare(sender, privkey, payload).generate_xml(val)
              }.to raise_error ArgumentError
            end
          end
        end

        it "generates valid xml" do
          doc = Nokogiri::XML::Document.parse(slap_xml)
          expect(doc.root.name).to eq("diaspora")
          expect(doc.at_xpath("d:diaspora/d:encrypted_header", ns).content).to_not be_empty
          expect(doc.xpath("d:diaspora/me:env", ns)).to have(1).item
        end

        it "can generate xml for two people" do
          slap = Salmon::EncryptedSlap.prepare(sender, privkey, payload)

          doc1 = Nokogiri::XML::Document.parse(slap.generate_xml(recipient_key.public_key))
          enc_header1 = doc1.at_xpath("d:diaspora/d:encrypted_header", ns).content
          cipher_header1 = JSON.parse(Base64.decode64(enc_header1))
          header_key1 = JSON.parse(recipient_key.private_decrypt(Base64.decode64(cipher_header1["aes_key"])))
          decrypted_header1 = Salmon::AES.decrypt(cipher_header1["ciphertext"],
                                                  Base64.decode64(header_key1["key"]),
                                                  Base64.decode64(header_key1["iv"]))

          recipient2_key = OpenSSL::PKey::RSA.generate(1024)
          doc2 = Nokogiri::XML::Document.parse(slap.generate_xml(recipient2_key.public_key))
          enc_header2 = doc2.at_xpath("d:diaspora/d:encrypted_header", ns).content
          cipher_header2 = JSON.parse(Base64.decode64(enc_header2))
          header_key2 = JSON.parse(recipient2_key.private_decrypt(Base64.decode64(cipher_header2["aes_key"])))
          decrypted_header2 = Salmon::AES.decrypt(cipher_header2["ciphertext"],
                                                  Base64.decode64(header_key2["key"]),
                                                  Base64.decode64(header_key2["iv"]))

          expect(enc_header1).not_to eq(enc_header2)
          expect(header_key1).not_to eq(header_key2)
          expect(decrypted_header1).to eq(decrypted_header2)
          expect(doc1.xpath("d:diaspora/me:env", ns).to_xml).to eq(doc2.xpath("d:diaspora/me:env", ns).to_xml)
        end

        it "does not add the sender to the magic envelope" do
          doc = Nokogiri::XML::Document.parse(slap_xml)
          expect(doc.at_xpath("d:diaspora/me:env/me:sig", ns)["key_id"]).to be_nil
        end

        context "header" do
          subject {
            doc = Nokogiri::XML::Document.parse(slap_xml)
            doc.at_xpath("d:diaspora/d:encrypted_header", ns).content
          }
          let(:cipher_header) { JSON.parse(Base64.decode64(subject)) }
          let(:header_key) {
            JSON.parse(recipient_key.private_decrypt(Base64.decode64(cipher_header["aes_key"])))
          }

          it "encodes the header correctly" do
            json_header = {}
            expect {
              json_header = JSON.parse(Base64.decode64(subject))
            }.not_to raise_error
            expect(json_header).to include("aes_key", "ciphertext")
          end

          it "encrypts the public_key encrypted header correctly" do
            key = {}
            expect {
              key = JSON.parse(recipient_key.private_decrypt(Base64.decode64(cipher_header["aes_key"])))
            }.not_to raise_error
            expect(key).to include("key", "iv")
          end

          it "encrypts the aes encrypted header correctly" do
            header = ""
            expect {
              header = Salmon::AES.decrypt(cipher_header["ciphertext"],
                                           Base64.decode64(header_key["key"]),
                                           Base64.decode64(header_key["iv"]))
            }.not_to raise_error
            header_doc = Nokogiri::XML::Document.parse(header)
            expect(header_doc.root.name).to eq("decrypted_header")
            expect(header_doc.xpath("//iv")).to have(1).item
            expect(header_doc.xpath("//aes_key")).to have(1).item
            expect(header_doc.xpath("//author_id")).to have(1).item
            expect(header_doc.at_xpath("//author_id").content).to eq(sender)
          end
        end
      end
    end

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
