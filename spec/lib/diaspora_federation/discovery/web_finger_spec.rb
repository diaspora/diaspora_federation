module DiasporaFederation
  describe Discovery::WebFinger do
    let(:person) { FactoryGirl.create(:person) }
    let(:acct) { "acct:#{person.diaspora_handle}" }
    let(:public_key_base64) { Base64.strict_encode64(person.serialized_public_key) }

    let(:xml) {
      <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Subject>#{acct}</Subject>
  <Alias>#{person.alias_url}</Alias>
  <Link rel="http://microformats.org/profile/hcard" type="text/html" href="#{person.hcard_url}"/>
  <Link rel="http://joindiaspora.com/seed_location" type="text/html" href="#{person.url}"/>
  <Link rel="http://joindiaspora.com/guid" type="text/html" href="#{person.guid}"/>
  <Link rel="http://webfinger.net/rel/profile-page" type="text/html" href="#{person.profile_url}"/>
  <Link rel="http://schemas.google.com/g/2010#updates-from" type="application/atom+xml" href="#{person.atom_url}"/>
  <Link rel="salmon" href="#{person.salmon_url}"/>
  <Link rel="diaspora-public-key" type="RSA" href="#{public_key_base64}"/>
</XRD>
XML
    }

    it "must not create blank instances" do
      expect { Discovery::WebFinger.new({}) }.to raise_error ArgumentError
    end

    context "generation" do
      it "creates a nice XML document" do
        wf = Discovery::WebFinger.new(
          acct_uri:    "acct:#{person.diaspora_handle}",
          alias_url:   person.alias_url,
          hcard_url:   person.hcard_url,
          seed_url:    person.url,
          profile_url: person.profile_url,
          atom_url:    person.atom_url,
          salmon_url:  person.salmon_url,
          guid:        person.guid,
          public_key:  person.serialized_public_key
        )
        expect(wf.to_xml).to eq(xml)
      end

      it "fails if nil was given" do
        expect { Discovery::WebFinger.new(nil) }.to raise_error ArgumentError, "expected a Hash"
      end
    end

    context "parsing" do
      it "reads its own output" do
        wf = Discovery::WebFinger.from_xml(xml)
        expect(wf.acct_uri).to eq(acct)
        expect(wf.alias_url).to eq(person.alias_url)
        expect(wf.hcard_url).to eq(person.hcard_url)
        expect(wf.seed_url).to eq(person.url)
        expect(wf.profile_url).to eq(person.profile_url)
        expect(wf.atom_url).to eq(person.atom_url)
        expect(wf.salmon_url).to eq(person.salmon_url)

        expect(wf.guid).to eq(person.guid)
        expect(wf.public_key).to eq(person.serialized_public_key)
      end

      it "is frozen after parsing" do
        wf = Discovery::WebFinger.from_xml(xml)
        expect(wf).to be_frozen
      end

      it "reads old-style XML" do
        historic_xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Subject>#{acct}</Subject>
  <Alias>#{person.alias_url}</Alias>
  <Link rel="http://microformats.org/profile/hcard" type="text/html" href="#{person.hcard_url}"/>
  <Link rel="http://joindiaspora.com/seed_location" type = "text/html" href="#{person.url}"/>
  <Link rel="http://joindiaspora.com/guid" type = "text/html" href="#{person.guid}"/>

  <Link rel="http://webfinger.net/rel/profile-page" type="text/html" href="#{person.profile_url}"/>
  <Link rel="http://schemas.google.com/g/2010#updates-from" type="application/atom+xml" href="#{person.atom_url}"/>
  <Link rel="salmon" href="#{person.salmon_url}"/>

  <Link rel="diaspora-public-key" type = "RSA" href="#{public_key_base64}"/>
</XRD>
XML

        wf = Discovery::WebFinger.from_xml(historic_xml)
        expect(wf.acct_uri).to eq(acct)
        expect(wf.alias_url).to eq(person.alias_url)
        expect(wf.hcard_url).to eq(person.hcard_url)
        expect(wf.seed_url).to eq(person.url)
        expect(wf.profile_url).to eq(person.profile_url)
        expect(wf.atom_url).to eq(person.atom_url)
        expect(wf.salmon_url).to eq(person.salmon_url)

        expect(wf.guid).to eq(person.guid)
        expect(wf.public_key).to eq(person.serialized_public_key)
      end

      it "reads future XML without guid and public key" do
        future_xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Subject>#{acct}</Subject>
  <Alias>#{person.alias_url}</Alias>
  <Link rel="http://microformats.org/profile/hcard" type="text/html" href="#{person.hcard_url}"/>
  <Link rel="http://joindiaspora.com/seed_location" type="text/html" href="#{person.url}"/>
  <Link rel="http://webfinger.net/rel/profile-page" type="text/html" href="#{person.profile_url}"/>
  <Link rel="http://schemas.google.com/g/2010#updates-from" type="application/atom+xml" href="#{person.atom_url}"/>
  <Link rel="salmon" href="#{person.salmon_url}"/>
</XRD>
XML

        wf = Discovery::WebFinger.from_xml(future_xml)
        expect(wf.acct_uri).to eq(acct)
        expect(wf.alias_url).to eq(person.alias_url)
        expect(wf.hcard_url).to eq(person.hcard_url)
        expect(wf.seed_url).to eq(person.url)
        expect(wf.profile_url).to eq(person.profile_url)
        expect(wf.atom_url).to eq(person.atom_url)
        expect(wf.salmon_url).to eq(person.salmon_url)

        expect(wf.guid).to be_nil
        expect(wf.public_key).to be_nil
      end

      it "fails if the document is empty" do
        invalid_xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
</XRD>
XML
        expect { Discovery::WebFinger.from_xml(invalid_xml) }.to raise_error Discovery::InvalidData
      end

      it "fails if the document is not XML" do
        expect { Discovery::WebFinger.from_xml("") }.to raise_error Discovery::InvalidDocument
      end
    end
  end
end
