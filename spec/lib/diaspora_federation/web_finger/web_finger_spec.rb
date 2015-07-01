module DiasporaFederation
  describe WebFinger::WebFinger do
    let(:person) { FactoryGirl.create(:person) }
    let(:acct) { "acct:#{person.diaspora_handle}" }
    let(:public_key_base64) { Base64.strict_encode64(person.public_key) }

    let(:xml) {
      <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Subject>#{acct}</Subject>
  <Alias>#{person.alias_url}</Alias>
  <Link rel="http://microformats.org/profile/hcard" type="text/html" href="#{person.hcard_url}"/>
  <Link rel="http://joindiaspora.com/seed_location" type="text/html" href="#{person.seed_url}"/>
  <Link rel="http://joindiaspora.com/guid" type="text/html" href="#{person.guid}"/>
  <Link rel="http://webfinger.net/rel/profile-page" type="text/html" href="#{person.profile_url}"/>
  <Link rel="http://schemas.google.com/g/2010#updates-from" type="application/atom+xml" href="#{person.atom_url}"/>
  <Link rel="salmon" href="#{person.salmon_url}"/>
  <Link rel="diaspora-public-key" type="RSA" href="#{public_key_base64}"/>
</XRD>
XML
    }

    it "must not create blank instances" do
      expect { WebFinger::WebFinger.new }.to raise_error NameError
    end

    context "generation" do
      it "creates a nice XML document" do
        wf = WebFinger::WebFinger.from_person(person)
        expect(wf.to_xml).to eq(xml)
      end

      it "fails if nil was given" do
        expect { WebFinger::WebFinger.from_person(nil) }.to raise_error ArgumentError
      end
    end

    context "parsing" do
      it "reads its own output" do
        wf = WebFinger::WebFinger.from_xml(xml)
        expect(wf.acct_uri).to eq(acct)
        expect(wf.alias_url).to eq(person.alias_url)
        expect(wf.hcard_url).to eq(person.hcard_url)
        expect(wf.seed_url).to eq(person.seed_url)
        expect(wf.profile_url).to eq(person.profile_url)
        expect(wf.atom_url).to eq(person.atom_url)
        expect(wf.salmon_url).to eq(person.salmon_url)

        expect(wf.guid).to eq(person.guid)
        expect(wf.public_key).to eq(person.public_key)
      end

      it "reads old-style XML" do
        historic_xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Subject>#{acct}</Subject>
  <Alias>#{person.alias_url}</Alias>
  <Link rel="http://microformats.org/profile/hcard" type="text/html" href="#{person.hcard_url}"/>
  <Link rel="http://joindiaspora.com/seed_location" type = "text/html" href="#{person.seed_url}"/>
  <Link rel="http://joindiaspora.com/guid" type = "text/html" href="#{person.guid}"/>

  <Link rel="http://webfinger.net/rel/profile-page" type="text/html" href="#{person.profile_url}"/>
  <Link rel="http://schemas.google.com/g/2010#updates-from" type="application/atom+xml" href="#{person.atom_url}"/>
  <Link rel="salmon" href="#{person.salmon_url}"/>

  <Link rel="diaspora-public-key" type = "RSA" href="#{public_key_base64}"/>
</XRD>
XML

        wf = WebFinger::WebFinger.from_xml(historic_xml)
        expect(wf.acct_uri).to eq(acct)
        expect(wf.alias_url).to eq(person.alias_url)
        expect(wf.hcard_url).to eq(person.hcard_url)
        expect(wf.seed_url).to eq(person.seed_url)
        expect(wf.profile_url).to eq(person.profile_url)
        expect(wf.atom_url).to eq(person.atom_url)
        expect(wf.salmon_url).to eq(person.salmon_url)

        expect(wf.guid).to eq(person.guid)
        expect(wf.public_key).to eq(person.public_key)
      end

      it "fails if the document is empty" do
        invalid_xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
</XRD>
XML
        expect { WebFinger::WebFinger.from_xml(invalid_xml) }.to raise_error WebFinger::InvalidData
      end

      it "fails if the document is not XML" do
        expect { WebFinger::WebFinger.from_xml("") }.to raise_error WebFinger::InvalidDocument
      end
    end
  end
end
