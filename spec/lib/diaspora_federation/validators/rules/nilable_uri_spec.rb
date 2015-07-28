describe Validation::Rule::NilableURI do
  it "has an error key" do
    expect(described_class.new.error_key).to eq(:nilableURI)
  end

  context "validation" do
    it "validates a valid uri" do
      validator = Validation::Validator.new(OpenStruct.new(uri: "http://example.com"))
      validator.rule(:uri, :nilableURI)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "validates nil" do
      validator = Validation::Validator.new(OpenStruct.new(uri: nil))
      validator.rule(:uri, :nilableURI)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "fails when given an invalid uri" do
      validator = Validation::Validator.new(OpenStruct.new(uri: "foo:/%urim"))
      validator.rule(:uri, :nilableURI)

      expect(validator).not_to be_valid
      expect(validator.errors).to include(:uri)
    end

    context "part validation" do
      it "fails to validate when given a uri without a host" do
        validator = Validation::Validator.new(OpenStruct.new(uri: "http:foo@"))
        validator.rule(:uri, :nilableURI)

        expect(validator).not_to be_valid
        expect(validator.errors).to include(:uri)
      end

      it "fails to validate when given a uri without a scheme" do
        validator = Validation::Validator.new(OpenStruct.new(uri: "example.com"))
        validator.rule(:uri, :nilableURI)

        expect(validator).not_to be_valid
        expect(validator.errors).to include(:uri)
      end

      it "fails to validate when given a uri without a path" do
        validator = Validation::Validator.new(OpenStruct.new(uri: "http://example.com"))
        validator.rule(:uri, nilableURI: %i(host path))

        expect(validator).not_to be_valid
        expect(validator.errors).to include(:uri)
      end
    end
  end
end
