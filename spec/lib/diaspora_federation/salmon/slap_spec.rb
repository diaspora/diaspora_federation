module DiasporaFederation
  describe Salmon::Slap do
    let(:sender) { "test_user@pod.somedomain.tld" }
    let(:privkey) { OpenSSL::PKey::RSA.generate(512) } # use small key for speedy specs
    let(:payload) { Entities::TestEntity.new(test: "qwertzuiop") }
    let(:slap_xml) { Salmon::Slap.generate_xml(sender, privkey, payload) }

    describe ".generate_xml" do
      context "sanity" do
        it "accepts correct params" do
          expect {
            Salmon::Slap.generate_xml(sender, privkey, payload)
          }.not_to raise_error
        end

        it "raises an error when the sender is the wrong type" do
          [1234, true, :symbol, payload, privkey].each do |val|
            expect {
              Salmon::Slap.generate_xml(val, privkey, payload)
            }.to raise_error ArgumentError
          end
        end

        it "raises an error when the privkey is the wrong type" do
          ["asdf", 1234, true, :symbol, payload].each do |val|
            expect {
              Salmon::Slap.generate_xml(sender, val, payload)
            }.to raise_error ArgumentError
          end
        end

        it "raises an error when the payload is the wrong type" do
          ["asdf", 1234, true, :symbol, privkey].each do |val|
            expect {
              Salmon::Slap.generate_xml(sender, privkey, val)
            }.to raise_error ArgumentError
          end
        end
      end

      it "generates valid xml" do
        ns = {d: Salmon::XMLNS, me: Salmon::MagicEnvelope::XMLNS}
        doc = Nokogiri::XML::Document.parse(slap_xml)
        expect(doc.root.name).to eq("diaspora")
        expect(doc.at_xpath("d:diaspora/d:header/d:author_id", ns).content).to eq(sender)
        expect(doc.xpath("d:diaspora/me:env", ns)).to have(1).item
      end
    end

    describe ".from_xml" do
      context "sanity" do
        it "accepts salmon xml as param" do
          allow(DiasporaFederation.callbacks).to receive(:trigger).with(
            :fetch_public_key_by_diaspora_id, sender
          ).and_return(privkey.public_key)

          expect {
            Salmon::Slap.from_xml(slap_xml)
          }.not_to raise_error
        end

        it "raises an error when the param has a wrong type" do
          [1234, false, :symbol, payload, privkey].each do |val|
            expect {
              Salmon::Slap.from_xml(val)
            }.to raise_error ArgumentError
          end
        end

        it "verifies the existence of an author_id" do
          faulty_xml = <<XML
<diaspora xmlns="https://joindiaspora.com/protocol" xmlns:me="http://salmon-protocol.org/ns/magic-env">
  <header/>
</diaspora>
XML
          expect {
            Salmon::Slap.from_xml(faulty_xml)
          }.to raise_error Salmon::MissingAuthor
        end

        it "verifies the existence of a magic envelope" do
          faulty_xml = <<-XML
<diaspora xmlns="https://joindiaspora.com/protocol" xmlns:me="http://salmon-protocol.org/ns/magic-env">
  <header>
    <author_id>#{sender}</author_id>
  </header>
</diaspora>
XML
          expect {
            Salmon::Slap.from_xml(faulty_xml)
          }.to raise_error Salmon::MissingMagicEnvelope
        end
      end

      context "generated instance" do
        it_behaves_like "a MagicEnvelope instance" do
          subject { Salmon::Slap.from_xml(slap_xml) }
        end
      end
    end
  end
end
