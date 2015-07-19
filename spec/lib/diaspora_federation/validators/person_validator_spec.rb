module DiasporaFederation
  describe Validators::PersonValidator do
    it "validates a well-formed instance" do
      instance = OpenStruct.new(FactoryGirl.attributes_for(:person_entity))
      validator = Validators::PersonValidator.new(instance)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it_behaves_like "a diaspora_handle validator" do
      let(:entity) { :person_entity }
      let(:validator_class) { Validators::PersonValidator }
      let(:property) { :diaspora_handle }
    end

    it_behaves_like "a guid validator" do
      let(:entity) { :person_entity }
      let(:validator_class) { Validators::PersonValidator }
      let(:property) { :guid }
    end

    context "#exported_key" do
      it "fails for malformed rsa key" do
        instance = OpenStruct.new(FactoryGirl.attributes_for(:person_entity, exported_key: "ASDF"))
        validator = Validators::PersonValidator.new(instance)

        expect(validator).not_to be_valid
        expect(validator.errors).to include(:exported_key)
      end

      it "must not be empty" do
        instance = OpenStruct.new(FactoryGirl.attributes_for(:person_entity, exported_key: ""))
        validator = Validators::PersonValidator.new(instance)

        expect(validator).not_to be_valid
        expect(validator.errors).to include(:exported_key)
      end
    end
  end
end
