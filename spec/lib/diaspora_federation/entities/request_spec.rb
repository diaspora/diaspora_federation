module DiasporaFederation
  describe Entities::Request do
    let(:data) { FactoryGirl.attributes_for(:request_entity) }

    let(:xml) {
      <<-XML
<request>
  <sender_handle>#{data[:author]}</sender_handle>
  <recipient_handle>#{data[:recipient]}</recipient_handle>
</request>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    describe "#to_contact" do
      it "copies the attributes to a Contact" do
        request = FactoryGirl.build(:request_entity)
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
        contact = Entities::Request.from_xml(Nokogiri::XML::Document.parse(xml).root)
        expect(contact).to be_a(Entities::Contact)
      end
    end
  end
end
