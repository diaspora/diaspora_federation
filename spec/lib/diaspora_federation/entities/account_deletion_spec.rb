module DiasporaFederation
  describe Entities::AccountDeletion do
    let(:data) { FactoryGirl.attributes_for(:account_deletion_entity) }

    let(:xml) { <<-XML }
<account_deletion>
  <diaspora_handle>#{data[:author]}</diaspora_handle>
</account_deletion>
XML

    let(:string) { "AccountDeletion:#{data[:author]}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
