module DiasporaFederation
  describe Entities::Request do
    let(:data) { Fabricate.attributes_for(:request_entity) }

    let(:xml) { <<-XML }
<request>
  <author>#{data[:author]}</author>
  <recipient>#{data[:recipient]}</recipient>
</request>
XML

    let(:string) { "Request:#{data[:author]}:#{data[:recipient]}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    describe "#to_contact" do
      it "copies the attributes to a Contact" do
        request = Fabricate(:request_entity)
        contact = request.to_contact

        expect(contact).to be_a(Entities::Contact)
        expect(contact.author).to eq(request.author)
        expect(contact.recipient).to eq(request.recipient)
        expect(contact.following).to be_truthy
        expect(contact.sharing).to be_truthy
      end
    end

    context "parse contact" do
      it "parses the xml as a contact" do
        contact = Entities::Request.from_xml(Nokogiri::XML(xml).root)
        expect(contact).to be_a(Entities::Contact)
      end
    end
  end
end
