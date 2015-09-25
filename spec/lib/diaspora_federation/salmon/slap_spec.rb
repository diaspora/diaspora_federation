module DiasporaFederation
  describe Salmon::Slap do
    let(:author_id) { "test_user@pod.somedomain.tld" }
    let(:pkey) { OpenSSL::PKey::RSA.generate(512) } # use small key for speedy specs
    let(:entity) { Entities::TestEntity.new(test: "qwertzuiop") }
    let(:slap) { Salmon::Slap.generate_xml(author_id, pkey, entity) }

    context ".generate_xml" do
      context "sanity" do
        it "accepts correct params" do
          expect {
            Salmon::Slap.generate_xml(author_id, pkey, entity)
          }.not_to raise_error
        end

        it "raises an error when the params are the wrong type" do
          ["asdf", 1234, true, :symbol, entity, pkey].each do |val|
            expect {
              Salmon::Slap.generate_xml(val, val, val)
            }.to raise_error ArgumentError
          end
        end
      end

      it "generates valid xml" do
        ns = {d: Salmon::XMLNS, me: Salmon::MagicEnvelope::XMLNS}
        doc = Nokogiri::XML::Document.parse(slap)
        expect(doc.root.name).to eq("diaspora")
        expect(doc.at_xpath("d:diaspora/d:header/d:author_id", ns).content).to eq(author_id)
        expect(doc.xpath("d:diaspora/me:env", ns)).to have(1).item
      end
    end

    context ".from_xml" do
      context "sanity" do
        it "accepts salmon xml as param" do
          expect {
            Salmon::Slap.from_xml(slap)
          }.not_to raise_error
        end

        it "raises an error when the param has a wrong type" do
          [1234, false, :symbol, entity, pkey].each do |val|
            expect {
              Salmon::Slap.from_xml(val)
            }.to raise_error ArgumentError
          end
        end

        it "verifies the existence of an author_id" do
          faulty_xml = <<XML
<diaspora>
  <header/>
</diaspora>
XML
          expect {
            Salmon::Slap.from_xml(faulty_xml)
          }.to raise_error Salmon::MissingAuthor
        end

        it "verifies the existence of a magic envelope" do
          faulty_xml = <<-XML
<diaspora>
  <header>
    <author_id>#{author_id}</author_id>
  </header>
</diaspora>
XML
          expect {
            Salmon::Slap.from_xml(faulty_xml)
          }.to raise_error Salmon::MissingMagicEnvelope
        end
      end
    end
  end
end
