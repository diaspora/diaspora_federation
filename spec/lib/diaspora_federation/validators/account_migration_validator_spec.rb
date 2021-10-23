module DiasporaFederation
  describe Validators::AccountMigrationValidator do
    let(:entity) { :account_migration_entity }

    it_behaves_like "a common validator"

    it_behaves_like "a diaspora* ID validator" do
      let(:property) { :author }
    end

    describe "#profile" do
      it_behaves_like "a property with a value validation/restriction" do
        let(:property) { :profile }
        let(:wrong_values) { [nil] }
        let(:correct_values) { [] }
      end
    end

    describe "#old_identity" do
      it_behaves_like "a diaspora* ID validator" do
        let(:property) { :old_identity }
      end
    end

    describe "#remote_photo_path" do
      let(:property) { :remote_photo_path }

      it_behaves_like "a property with a value validation/restriction" do
        let(:wrong_values) { [] }
        let(:correct_values) { [nil] }
      end

      it_behaves_like "a url path validator"
    end
  end
end
