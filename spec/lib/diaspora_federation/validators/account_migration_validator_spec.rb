module DiasporaFederation
  describe Validators::AccountMigrationValidator do
    let(:entity) { :account_migration_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a diaspora* ID validator" do
      let(:property) { :author }
      let(:mandatory) { true }
    end

    describe "#person" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :profile }
        let(:wrong_values) { [nil] }
        let(:correct_values) { [] }
      end
    end
  end
end
