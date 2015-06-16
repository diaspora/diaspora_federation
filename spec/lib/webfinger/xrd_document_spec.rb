module DiasporaFederation
  describe WebFinger::XrdDocument do
    xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <Expires>2010-01-30T09:30:00Z</Expires>
  <Subject>http://blog.example.com/article/id/314</Subject>
  <Alias>http://blog.example.com/cool_new_thing</Alias>
  <Alias>http://blog.example.com/steve/article/7</Alias>
  <Property type="http://blgx.example.net/ns/version">1.3</Property>
  <Property type="http://blgx.example.net/ns/ext"/>
  <Link rel="author" type="text/html" href="http://blog.example.com/author/steve"/>
  <Link rel="author" href="http://example.com/author/john"/>
  <Link rel="copyright" template="http://example.com/copyright?id={uri}"/>
</XRD>
XML

    data = {
      subject:    "http://blog.example.com/article/id/314",
      expires:    DateTime.parse("2010-01-30T09:30:00Z"),
      aliases:    %w(
        http://blog.example.com/cool_new_thing
        http://blog.example.com/steve/article/7
      ),
      properties: {
        "http://blgx.example.net/ns/version" => "1.3",
        "http://blgx.example.net/ns/ext"     => nil
      },
      links:      [
        {
          rel:  "author",
          type: "text/html",
          href: "http://blog.example.com/author/steve"
        },
        {
          rel:  "author",
          href: "http://example.com/author/john"
        },
        {
          rel:      "copyright",
          template: "http://example.com/copyright?id={uri}"
        }
      ]
    }

    it "creates the xml document" do
      doc = WebFinger::XrdDocument.new
      doc.expires = data[:expires]
      doc.subject = data[:subject]

      data[:aliases].each do |a|
        doc.aliases << a
      end

      data[:properties].each do |t, v|
        doc.properties[t] = v
      end

      data[:links].each do |h|
        doc.links << h
      end

      expect(doc.to_xml).to eq(xml)
    end

    it "reads the xml document" do
      doc = WebFinger::XrdDocument.xml_data(xml)
      expect(doc).to eq(data)
    end
  end
end
