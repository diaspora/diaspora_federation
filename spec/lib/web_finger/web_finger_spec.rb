module DiasporaFederation
  describe WebFinger::WebFinger do
    acct = "acct:user@pod.example.tld"
    alias_url = "http://pod.example.tld/"
    hcard_url = "https://pod.example.tld/hcard/users/abcdef0123456789"
    seed_url = "https://pod.geraspora.de/"
    guid = "abcdef0123456789"
    profile_url = "https://pod.example.tld/u/user"
    atom_url = "https://pod.example.tld/public/user.atom"
    salmon_url = "https://pod.example.tld/receive/users/abcdef0123456789"
    pubkey = "AAAAAA=="

    xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Subject>#{acct}</Subject>
  <Alias>#{alias_url}</Alias>
  <Link rel="http://microformats.org/profile/hcard" type="text/html" href="#{hcard_url}"/>
  <Link rel="http://joindiaspora.com/seed_location" type="text/html" href="#{seed_url}"/>
  <Link rel="http://joindiaspora.com/guid" type="text/html" href="#{guid}"/>
  <Link rel="http://webfinger.net/rel/profile-page" type="text/html" href="#{profile_url}"/>
  <Link rel="http://schemas.google.com/g/2010#updates-from" type="application/atom+xml" href="#{atom_url}"/>
  <Link rel="salmon" href="#{salmon_url}"/>
  <Link rel="diaspora-public-key" type="RSA" href="#{pubkey}"/>
</XRD>
XML

    it "must not create blank instances" do
      expect { WebFinger::WebFinger.new }.to raise_error
    end

    context "generation" do
      it "creates a nice XML document" do
        wf = WebFinger::WebFinger.from_account(
          acct_uri:    acct,
          alias_url:   alias_url,
          hcard_url:   hcard_url,
          seed_url:    seed_url,
          profile_url: profile_url,
          atom_url:    atom_url,
          salmon_url:  salmon_url,
          guid:        guid,
          pubkey:      pubkey
        )
        expect(wf.to_xml).to eq(xml)
      end

      it "fails if some params are missing" do
        expect {
          WebFinger::WebFinger.from_account(
            acct_uri:  acct,
            alias_url: alias_url,
            hcard_url: hcard_url
          )
        }.to raise_error(WebFinger::InvalidData)
      end

      it "fails if empty was given" do
        expect { WebFinger::WebFinger.from_account({}) }.to raise_error(WebFinger::InvalidData)
      end

      it "fails if nil was given" do
        expect { WebFinger::WebFinger.from_account(nil) }.to raise_error(WebFinger::InvalidData)
      end
    end

    context "parsing" do
      it "reads its own output" do
        wf = WebFinger::WebFinger.from_xml(xml)
        expect(wf.acct_uri).to eq(acct)
        expect(wf.alias_url).to eq(alias_url)
        expect(wf.hcard_url).to eq(hcard_url)
        expect(wf.seed_url).to eq(seed_url)
        expect(wf.profile_url).to eq(profile_url)
        expect(wf.atom_url).to eq(atom_url)
        expect(wf.salmon_url).to eq(salmon_url)

        expect(wf.guid).to eq(guid)
        expect(wf.pubkey).to eq(pubkey)
      end

      it "reads old-style XML" do
        historic_xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Subject>#{acct}</Subject>
  <Alias>#{alias_url}</Alias>
  <Link rel="http://microformats.org/profile/hcard" type="text/html" href="#{hcard_url}"/>
  <Link rel="http://joindiaspora.com/seed_location" type = "text/html" href="#{seed_url}"/>
  <Link rel="http://joindiaspora.com/guid" type = "text/html" href="#{guid}"/>

  <Link rel="http://webfinger.net/rel/profile-page" type="text/html" href="#{profile_url}"/>
  <Link rel="http://schemas.google.com/g/2010#updates-from" type="application/atom+xml" href="#{atom_url}"/>
  <Link rel="salmon" href="#{salmon_url}"/>

  <Link rel="diaspora-public-key" type = "RSA" href="#{pubkey}"/>
</XRD>
XML

        wf = WebFinger::WebFinger.from_xml(historic_xml)
        expect(wf.acct_uri).to eq(acct)
        expect(wf.alias_url).to eq(alias_url)
        expect(wf.hcard_url).to eq(hcard_url)
        expect(wf.seed_url).to eq(seed_url)
        expect(wf.profile_url).to eq(profile_url)
        expect(wf.atom_url).to eq(atom_url)
        expect(wf.salmon_url).to eq(salmon_url)

        expect(wf.guid).to eq(guid)
        expect(wf.pubkey).to eq(pubkey)
      end

      it "fails if the document is empty" do
        invalid_xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
</XRD>
XML
        expect { WebFinger::WebFinger.from_xml(invalid_xml) }.to raise_error(WebFinger::InvalidData)
      end

      it "fails if the document is not XML" do
        expect { WebFinger::WebFinger.from_xml("") }.to raise_error(WebFinger::InvalidDocument)
      end
    end
  end
end
