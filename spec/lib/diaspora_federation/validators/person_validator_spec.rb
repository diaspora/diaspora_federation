module DiasporaFederation
  describe Validators::PersonValidator do
    let(:entity) { :person_entity }

    it "validates a well-formed instance" do
      instance = OpenStruct.new(FactoryGirl.attributes_for(:person_entity))
      validator = Validators::PersonValidator.new(instance)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it_behaves_like "a diaspora id validator" do
      let(:property) { :diaspora_id }
      let(:mandatory) { true }
    end

    it_behaves_like "a guid validator" do
      let(:property) { :guid }
    end

    describe "#url" do
      it_behaves_like "a url validator without path" do
        let(:property) { :url }
      end
    end

    describe "#profile" do
      it "fails if profile is nil" do
        instance = OpenStruct.new(FactoryGirl.attributes_for(:person_entity, profile: nil))
        validator = Validators::PersonValidator.new(instance)

        expect(validator).not_to be_valid
        expect(validator.errors).to include(:profile)
      end
    end

    it_behaves_like "a public key validator" do
      let(:property) { :exported_key }
    end
  end
end
