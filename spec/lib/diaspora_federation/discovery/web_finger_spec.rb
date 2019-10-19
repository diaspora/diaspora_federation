# frozen_string_literal: true

module DiasporaFederation
  describe Discovery::WebFinger do
    let(:person) { Fabricate(:person) }
    let(:acct) { "acct:#{person.diaspora_id}" }
    let(:public_key_base64) { Base64.strict_encode64(person.serialized_public_key) }

    let(:data) {
      {
        acct_uri:      acct,
        hcard_url:     person.hcard_url,
        seed_url:      person.url,
        profile_url:   person.profile_url,
        atom_url:      person.atom_url,
        salmon_url:    person.salmon_url,
        subscribe_url: person.subscribe_url
      }
    }

    let(:xml) { <<-XML }
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Subject>#{acct}</Subject>
  <Alias>#{person.alias_url}</Alias>
  <Link rel="http://microformats.org/profile/hcard" type="text/html" href="#{person.hcard_url}"/>
  <Link rel="http://joindiaspora.com/seed_location" type="text/html" href="#{person.url}"/>
  <Link rel="http://webfinger.net/rel/profile-page" type="text/html" href="#{person.profile_url}"/>
  <Link rel="http://schemas.google.com/g/2010#updates-from" type="application/atom+xml" href="#{person.atom_url}"/>
  <Link rel="salmon" href="#{person.salmon_url}"/>
  <Link rel="http://ostatus.org/schema/1.0/subscribe" template="#{person.subscribe_url}"/>
</XRD>
XML

    let(:minimal_xml) { <<-XML }
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Subject>#{acct}</Subject>
  <Link rel="http://microformats.org/profile/hcard" type="text/html" href="#{person.hcard_url}"/>
  <Link rel="http://joindiaspora.com/seed_location" type="text/html" href="#{person.url}"/>
</XRD>
XML

    let(:json) { <<-JSON }
{
  "subject": "#{acct}",
  "aliases": [
    "#{person.alias_url}"
  ],
  "links": [
    {
      "rel": "http://microformats.org/profile/hcard",
      "type": "text/html",
      "href": "#{person.hcard_url}"
    },
    {
      "rel": "http://joindiaspora.com/seed_location",
      "type": "text/html",
      "href": "#{person.url}"
    },
    {
      "rel": "http://webfinger.net/rel/profile-page",
      "type": "text/html",
      "href": "#{person.profile_url}"
    },
    {
      "rel": "http://schemas.google.com/g/2010#updates-from",
      "type": "application/atom+xml",
      "href": "#{person.atom_url}"
    },
    {
      "rel": "salmon",
      "href": "#{person.salmon_url}"
    },
    {
      "rel": "http://ostatus.org/schema/1.0/subscribe",
      "template": "http://somehost:3000/people?q={uri}"
    }
  ]
}
JSON

    let(:minimal_json) { <<-JSON }
{
  "subject": "#{acct}",
  "links": [
    {
      "rel": "http://microformats.org/profile/hcard",
      "type": "text/html",
      "href": "#{person.hcard_url}"
    },
    {
      "rel": "http://joindiaspora.com/seed_location",
      "type": "text/html",
      "href": "#{person.url}"
    }
  ]
}
JSON

    let(:string) { "WebFinger:#{data[:acct_uri]}" }

    it_behaves_like "an Entity subclass"

    context "generation" do
      let(:minimal_data) { {acct_uri: acct, hcard_url: person.hcard_url, seed_url: person.url} }
      let(:additional_data) {
        {
          aliases:    [person.alias_url, person.profile_url],
          properties: {"http://webfinger.example/ns/name" => "Bob Smith"},
          links:      [
            {rel: "http://portablecontacts.net/spec/1.0", href: "https://pod.example.tld/poco/trouble"},
            {
              rel:  "http://webfinger.net/rel/avatar",
              type: "image/jpeg",
              href: "http://localhost:3000/assets/user/default.png"
            },
            {rel: "http://openid.net/specs/connect/1.0/issuer", href: "https://pod.example.tld/"}
          ]
        }
      }

      context "xml" do
        it "creates a nice XML document" do
          wf = Discovery::WebFinger.new(data, aliases: [person.alias_url])
          expect(wf.to_xml).to eq(xml)
        end

        it "creates minimal XML document" do
          wf = Discovery::WebFinger.new(minimal_data)
          expect(wf.to_xml).to eq(minimal_xml)
        end

        it "creates XML document with additional data" do
          xml_with_additional_data = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Subject>#{acct}</Subject>
  <Alias>#{person.alias_url}</Alias>
  <Alias>#{person.profile_url}</Alias>
  <Property type="http://webfinger.example/ns/name">Bob Smith</Property>
  <Link rel="http://microformats.org/profile/hcard" type="text/html" href="#{person.hcard_url}"/>
  <Link rel="http://joindiaspora.com/seed_location" type="text/html" href="#{person.url}"/>
  <Link rel="http://portablecontacts.net/spec/1.0" href="https://pod.example.tld/poco/trouble"/>
  <Link rel="http://webfinger.net/rel/avatar" type="image/jpeg" href="http://localhost:3000/assets/user/default.png"/>
  <Link rel="http://openid.net/specs/connect/1.0/issuer" href="https://pod.example.tld/"/>
</XRD>
XML

          wf = Discovery::WebFinger.new(minimal_data, additional_data)
          expect(wf.to_xml).to eq(xml_with_additional_data)
        end
      end

      context "json" do
        it "creates a nice JSON document" do
          wf = Discovery::WebFinger.new(data, aliases: [person.alias_url])
          expect(JSON.pretty_generate(wf.to_json)).to eq(json.strip)
        end

        it "creates minimal JSON document" do
          wf = Discovery::WebFinger.new(minimal_data)
          expect(JSON.pretty_generate(wf.to_json)).to eq(minimal_json.strip)
        end

        it "creates JSON document with additional data" do
          json_with_additional_data = <<-JSON
{
  "subject": "#{acct}",
  "aliases": [
    "#{person.alias_url}",
    "#{person.profile_url}"
  ],
  "properties": {
    "http://webfinger.example/ns/name": "Bob Smith"
  },
  "links": [
    {
      "rel": "http://microformats.org/profile/hcard",
      "type": "text/html",
      "href": "#{person.hcard_url}"
    },
    {
      "rel": "http://joindiaspora.com/seed_location",
      "type": "text/html",
      "href": "#{person.url}"
    },
    {
      "rel": "http://portablecontacts.net/spec/1.0",
      "href": "https://pod.example.tld/poco/trouble"
    },
    {
      "rel": "http://webfinger.net/rel/avatar",
      "type": "image/jpeg",
      "href": "http://localhost:3000/assets/user/default.png"
    },
    {
      "rel": "http://openid.net/specs/connect/1.0/issuer",
      "href": "https://pod.example.tld/"
    }
  ]
}
JSON

          wf = Discovery::WebFinger.new(minimal_data, additional_data)
          expect(JSON.pretty_generate(wf.to_json)).to eq(json_with_additional_data.strip)
        end
      end
    end

    context "parsing" do
      it "reads its own xml output" do
        wf = Discovery::WebFinger.from_xml(xml)
        expect(wf.acct_uri).to eq(acct)
        expect(wf.hcard_url).to eq(person.hcard_url)
        expect(wf.seed_url).to eq(person.url)
        expect(wf.profile_url).to eq(person.profile_url)
        expect(wf.atom_url).to eq(person.atom_url)
        expect(wf.salmon_url).to eq(person.salmon_url)
        expect(wf.subscribe_url).to eq(person.subscribe_url)
      end

      it "reads minimal xml" do
        wf = Discovery::WebFinger.from_xml(minimal_xml)
        expect(wf.acct_uri).to eq(acct)
        expect(wf.hcard_url).to eq(person.hcard_url)
        expect(wf.seed_url).to eq(person.url)
      end

      it "reads its own json output" do
        wf = Discovery::WebFinger.from_json(json)
        expect(wf.acct_uri).to eq(acct)
        expect(wf.hcard_url).to eq(person.hcard_url)
        expect(wf.seed_url).to eq(person.url)
        expect(wf.profile_url).to eq(person.profile_url)
        expect(wf.atom_url).to eq(person.atom_url)
        expect(wf.salmon_url).to eq(person.salmon_url)
        expect(wf.subscribe_url).to eq(person.subscribe_url)
      end

      it "reads minimal json" do
        wf = Discovery::WebFinger.from_json(minimal_json)
        expect(wf.acct_uri).to eq(acct)
        expect(wf.hcard_url).to eq(person.hcard_url)
        expect(wf.seed_url).to eq(person.url)
      end

      it "is frozen after parsing" do
        wf = Discovery::WebFinger.from_xml(xml)
        expect(wf).to be_frozen
      end

      it "reads friendica XML (two aliases, first with acct)" do
        friendica_xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">

    <Subject>#{acct}</Subject>
    <Alias>#{acct}</Alias>
    <Alias>#{person.alias_url}</Alias>

    <Link rel="http://purl.org/macgirvin/dfrn/1.0"
          href="#{person.profile_url}" />
    <Link rel="http://schemas.google.com/g/2010#updates-from"
          type="application/atom+xml"
          href="#{person.atom_url}" />
    <Link rel="http://webfinger.net/rel/profile-page"
          type="text/html"
          href="#{person.profile_url}" />
    <Link rel="http://microformats.org/profile/hcard"
          type="text/html"
          href="#{person.hcard_url}" />
    <Link rel="http://portablecontacts.net/spec/1.0"
          href="https://pod.example.tld/poco/trouble" />
    <Link rel="http://webfinger.net/rel/avatar"
          type="image/jpeg"
          href="http://localhost:3000/assets/user/default.png" />
    <Link rel="http://joindiaspora.com/seed_location" type="text/html" href="#{person.url}" />
    <Link rel="http://joindiaspora.com/guid" type="text/html" href="#{person.guid}" />
    <Link rel="diaspora-public-key" type="RSA" href="#{public_key_base64}" />

    <Link rel="salmon"
          href="#{person.salmon_url}" />
    <Link rel="http://salmon-protocol.org/ns/salmon-replies"
          href="https://pod.example.tld/salmon/trouble" />
    <Link rel="http://salmon-protocol.org/ns/salmon-mention"
          href="https://pod.example.tld/salmon/trouble/mention" />
    <Link rel="http://ostatus.org/schema/1.0/subscribe"
          template="https://pod.example.tld/follow?url={uri}" />
    <Link rel="magic-public-key"
          href="data:application/magic-public-key,RSA.abcdef1234567890" />

    <Property xmlns:mk="http://salmon-protocol.org/ns/magic-key"
          type="http://salmon-protocol.org/ns/magic-key"
          mk:key_id="1">RSA.abcdef1234567890</Property>

</XRD>
        XML

        wf = Discovery::WebFinger.from_xml(friendica_xml)
        expect(wf.acct_uri).to eq(acct)
        expect(wf.hcard_url).to eq(person.hcard_url)
        expect(wf.seed_url).to eq(person.url)
        expect(wf.profile_url).to eq(person.profile_url)
        expect(wf.atom_url).to eq(person.atom_url)
        expect(wf.salmon_url).to eq(person.salmon_url)
        expect(wf.subscribe_url).to eq("https://pod.example.tld/follow?url={uri}")
      end

      it "reads redmatrix XML (no alias)" do
        redmatrix_xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">

    <Subject>#{person.diaspora_id}</Subject>

    <Link rel="http://schemas.google.com/g/2010#updates-from"
          type="application/atom+xml"
          href="#{person.atom_url}" />
    <Link rel="http://webfinger.net/rel/profile-page"
          type="text/html"
          href="#{person.profile_url}" />
    <Link rel="http://portablecontacts.net/spec/1.0"
          href="https://pod.example.tld/poco/trouble" />
    <Link rel="http://webfinger.net/rel/avatar"
          type="image/jpeg"
          href="http://localhost:3000/assets/user/default.png" />
    <Link rel="http://microformats.org/profile/hcard"
          type="text/html"
          href="#{person.hcard_url}" />

    <Link rel="magic-public-key"
          href="data:application/magic-public-key,RSA.abcdef1234567890" />

    <Link rel="http://joindiaspora.com/seed_location" type="text/html" href="#{person.url}" />
    <Link rel="http://joindiaspora.com/guid" type="text/html" href="#{person.guid}" />
    <Link rel="diaspora-public-key" type="RSA" href="#{public_key_base64}" />

</XRD>
        XML

        wf = Discovery::WebFinger.from_xml(redmatrix_xml)
        expect(wf.acct_uri).to eq(person.diaspora_id)
        expect(wf.hcard_url).to eq(person.hcard_url)
        expect(wf.seed_url).to eq(person.url)
        expect(wf.profile_url).to eq(person.profile_url)
        expect(wf.atom_url).to eq(person.atom_url)
        expect(wf.salmon_url).to be_nil
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
