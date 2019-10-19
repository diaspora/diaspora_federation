# frozen_string_literal: true

module DiasporaFederation
  describe Entities::Request do
    let(:data) { {author: Fabricate.sequence(:diaspora_id), recipient: Fabricate.sequence(:diaspora_id)} }

    let(:xml) { <<~XML }
      <request>
        <sender_handle>#{data[:author]}</sender_handle>
        <recipient_handle>#{data[:recipient]}</recipient_handle>
      </request>
    XML

    describe "#initialize" do
      it "raises because it is not supported anymore" do
        expect {
          Entities::Request.new(data)
        }.to raise_error RuntimeError, "Sending Request is not supported anymore! Use Contact instead!"
      end
    end

    context "parse contact" do
      it "parses the xml as a contact" do
        contact = Entities::Request.from_xml(Nokogiri::XML(xml).root)
        expect(contact).to be_a(Entities::Contact)
        expect(contact.author).to eq(data[:author])
        expect(contact.recipient).to eq(data[:recipient])
        expect(contact.following).to be_truthy
        expect(contact.sharing).to be_truthy
      end
    end
  end
end
