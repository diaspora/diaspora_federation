module DiasporaFederation
  describe Entities::AccountDeletion do
    let(:data) { Fabricate.attributes_for(:account_deletion_entity) }

    let(:xml) { <<-XML }
<account_deletion>
  <author>#{data[:author]}</author>
</account_deletion>
XML

    let(:string) { "AccountDeletion:#{data[:author]}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
