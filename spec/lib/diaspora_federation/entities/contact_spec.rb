module DiasporaFederation
  describe Entities::Contact do
    let(:data) { FactoryGirl.attributes_for(:contact_entity) }

    let(:xml) { <<-XML }
<contact>
  <author>#{data[:author]}</author>
  <recipient>#{data[:recipient]}</recipient>
  <following>#{data[:following]}</following>
  <sharing>#{data[:sharing]}</sharing>
</contact>
XML

    let(:string) { "Contact:#{data[:author]}:#{data[:recipient]}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
