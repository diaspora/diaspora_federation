# frozen_string_literal: true

module DiasporaFederation
  describe Salmon::Slap do
    let(:sender) { "test_user@pod.somedomain.tld" }
    let(:privkey) { OpenSSL::PKey::RSA.generate(512) } # use small key for speedy specs
    let(:payload) { Entities::TestEntity.new(test: "qwertzuiop") }
    let(:slap_xml) { generate_legacy_salmon_slap(payload, sender, privkey) }

    describe ".from_xml" do
      context "sanity" do
        it "accepts salmon xml as param" do
          expect_callback(:fetch_public_key, sender).and_return(privkey.public_key)

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
