# frozen_string_literal: true

module DiasporaFederation
  describe Discovery::HostMeta do
    let(:base_url) { "https://pod.example.tld/" }
    let(:xml) { <<-XML }
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Link rel="lrdd" type="application/xrd+xml" template="#{base_url}.well-known/webfinger.xml?resource={uri}"/>
</XRD>
XML

    it "must not create blank instances" do
      expect { Discovery::HostMeta.new }.to raise_error NoMethodError
    end

    context "generation" do
      it "creates a nice XML document" do
        hm = Discovery::HostMeta.from_base_url(base_url)
        expect(hm.to_xml).to eq(xml)
      end

      it "converts object to string" do
        hm = Discovery::HostMeta.from_base_url(URI(base_url))
        expect(hm.to_xml).to eq(xml)
      end

      it "appends a '/' if necessary" do
        hm = Discovery::HostMeta.from_base_url("https://pod.example.tld")
        expect(hm.to_xml).to eq(xml)
      end

      it "fails if the base_url was omitted" do
        expect { Discovery::HostMeta.from_base_url("") }.to raise_error Discovery::InvalidData
      end
    end

    context "parsing" do
      it "parses its own output" do
        hm = Discovery::HostMeta.from_xml(xml)
        expect(hm.webfinger_template_url).to eq("#{base_url}.well-known/webfinger.xml?resource={uri}")
      end

      it "also reads old-style XML" do
        historic_xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">

  <!-- Resource-specific Information -->

  <Link rel="lrdd"
        type="application/xrd+xml"
        template="#{base_url}webfinger?q={uri}" />

</XRD>
XML
        hm = Discovery::HostMeta.from_xml(historic_xml)
        expect(hm.webfinger_template_url).to eq("#{base_url}webfinger?q={uri}")
      end

      it "also reads friendica/redmatrix XML" do
        friendica_redmatrix_xml = <<-XML
<?xml version='1.0' encoding='UTF-8'?>
<XRD xmlns='http://docs.oasis-open.org/ns/xri/xrd-1.0'
     xmlns:hm='http://host-meta.net/xrd/1.0'>

    <hm:Host>pod.example.tld</hm:Host>

    <Link rel='lrdd' template='#{base_url}xrd/?uri={uri}' />
    <Link rel="http://oexchange.org/spec/0.8/rel/resident-target" type="application/xrd+xml"
        href="https://pod.example.tld/oexchange/xrd" />

</XRD>
        XML
        hm = Discovery::HostMeta.from_xml(friendica_redmatrix_xml)
        expect(hm.webfinger_template_url).to eq("#{base_url}xrd/?uri={uri}")
      end

      it "fails if the document does not contain a webfinger url" do
        invalid_xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
</XRD>
XML
        expect { Discovery::HostMeta.from_xml(invalid_xml) }.to raise_error Discovery::InvalidData
      end

      it "fails if the document contains a malformed webfinger url" do
        invalid_xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Link rel="lrdd" type="application/xrd+xml" template="#{base_url}webfinger?q="/>
</XRD>
XML
        expect { Discovery::HostMeta.from_xml(invalid_xml) }.to raise_error Discovery::InvalidData
      end

      it "fails if the document is invalid" do
        expect { Discovery::HostMeta.from_xml("") }.to raise_error Discovery::InvalidDocument
      end
    end
  end
end
