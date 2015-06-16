module DiasporaFederation
  describe WebFinger::HostMeta do
    base_url = "https://pod.example.tld/"
    xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Link rel="lrdd" type="application/xrd+xml" template="#{base_url}webfinger?q={uri}"/>
</XRD>
XML

    it "must not create blank instances" do
      expect { WebFinger::HostMeta.new }.to raise_error(NoMethodError)
    end

    context "#to_xml" do
      it "creates a nice XML document" do
        hm = WebFinger::HostMeta.from_base_url(base_url)
        expect(hm.to_xml).to eq(xml)
      end

      it "appends a '/' if necessary" do
        hm = WebFinger::HostMeta.from_base_url("https://pod.example.tld")
        expect(hm.to_xml).to eq(xml)
      end

      it "fails if the base_url was omitted" do
        expect { WebFinger::HostMeta.from_base_url("") }.to raise_error(WebFinger::HostMeta::InvalidData)
      end
    end

    context "#webfinger_template_url" do
      it "parses its own output" do
        hm = WebFinger::HostMeta.from_xml(xml)
        expect(hm.webfinger_template_url).to eq("#{base_url}webfinger?q={uri}")
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
        hm = WebFinger::HostMeta.from_xml(historic_xml)
        expect(hm.webfinger_template_url).to eq("#{base_url}webfinger?q={uri}")
      end

      it "fails if the document does not contain a webfinger url" do
        invalid_xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
</XRD>
XML
        expect { WebFinger::HostMeta.from_xml(invalid_xml) }.to raise_error(WebFinger::HostMeta::InvalidData)
      end

      it "fails if the document contains a malformed webfinger url" do
        invalid_xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Link rel="lrdd" type="application/xrd+xml" template="#{base_url}webfinger?q="/>
</XRD>
XML
        expect { WebFinger::HostMeta.from_xml(invalid_xml) }.to raise_error(WebFinger::HostMeta::InvalidData)
      end

      it "fails if the document is invalid" do
        expect { WebFinger::HostMeta.from_xml("") }.to raise_error(WebFinger::XrdDocument::InvalidDocument)
      end
    end
  end
end
