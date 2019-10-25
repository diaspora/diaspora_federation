# frozen_string_literal: true

module DiasporaFederation
  describe Validators::AccountDeletionValidator do
    let(:entity) { :account_deletion_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a diaspora* ID validator" do
      let(:property) { :author }
    end
  end
end
