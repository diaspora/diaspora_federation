module DiasporaFederation
  describe Validators::OptionalAwareValidator do
    let(:entity_data) {
      {test1: "abc", test2: true, test7: "abc", multi: []}
    }

    it "validates a valid object" do
      validator = Validators::TestComplexEntityValidator.new(OpenStruct.new(entity_data))
      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "fails when a mandatory property is invalid" do
      ["ab", nil].each do |val|
        entity = OpenStruct.new(entity_data.merge(test1: val))
        validator = Validators::TestComplexEntityValidator.new(entity)
        expect(validator).not_to be_valid
        expect(validator.errors).to include(:test1)
      end
    end

    it "fails when an optional property is invalid" do
      entity = OpenStruct.new(entity_data.merge(test7: "ab"))
      validator = Validators::TestComplexEntityValidator.new(entity)
      expect(validator).not_to be_valid
      expect(validator.errors).to include(:test7)
    end

    it "allows an optional property to be nil" do
      entity = OpenStruct.new(entity_data.merge(test7: nil))
      validator = Validators::TestComplexEntityValidator.new(entity)
      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "doesn't ignore 'not_nil' rules for an optional property" do
      entity = OpenStruct.new(entity_data.merge(multi: nil))
      validator = Validators::TestComplexEntityValidator.new(entity)
      expect(validator).not_to be_valid
      expect(validator.errors).to include(:multi)
    end

    it "doesn't fail when there is no entity for this validator" do
      entity = OpenStruct.new(entity_data.merge(test1: nil))
      validator = Validators::TestUnknownEntityValidator.new(entity)
      expect(validator).not_to be_valid
      expect(validator.errors).to include(:test1)
    end
  end
end
