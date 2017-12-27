module DiasporaFederation
  describe Entities::AccountMigration::Signable do
    let(:entity) { TestAMSignableEntity.new({}) }

    class TestAMSignableEntity < Entity
      include Entities::AccountMigration::Signable

      property :my_signature, :string, default: nil

      def old_identity
        "old"
      end

      def new_identity
        "new"
      end
    end

    it_behaves_like "a signable" do
      let(:test_class) { TestAMSignableEntity }
      let(:test_string) { "AccountMigration:old:new" }
    end

    describe "#unique_migration_descriptor" do
      it "composes a string using #old_identity and #new_identity" do
        expect(entity.unique_migration_descriptor).to eq("AccountMigration:old:new")
      end
    end

    describe "#signature_data" do
      it "delegates to #unique_migration_descriptor" do
        expect(entity.signature_data).to eq("AccountMigration:old:new")
      end
    end
  end
end
