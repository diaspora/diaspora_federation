module DiasporaFederation
  describe Validators::AccountDeletionValidator do
    let(:entity) { :account_deletion_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a diaspora id validator" do
      let(:property) { :author }
      let(:mandatory) { true }
    end
  end
end
