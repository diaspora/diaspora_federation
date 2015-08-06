describe Validation::Rule::NotNil do
  it "will not accept parameters" do
    validator = Validation::Validator.new({})
    expect {
      validator.rule(:not_nil, not_nil: {param: true})
    }.to raise_error ArgumentError
  end

  it "has an error key" do
    expect(described_class.new.error_key).to eq(:not_nil)
  end

  context "validation" do
    it "validates a string " do
      validator = Validation::Validator.new(OpenStruct.new(not_nil: "abcd"))
      validator.rule(:not_nil, :not_nil)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "validates a object " do
      validator = Validation::Validator.new(OpenStruct.new(not_nil: Object.new))
      validator.rule(:not_nil, :not_nil)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "fails if it is nil" do
      validator = Validation::Validator.new(OpenStruct.new(not_nil: nil))
      validator.rule(:not_nil, :not_nil)

      expect(validator).not_to be_valid
      expect(validator.errors).to include(:not_nil)
    end

    it "allows an empty string" do
      validator = Validation::Validator.new(OpenStruct.new(not_nil: ""))
      validator.rule(:not_nil, :not_nil)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end
  end
end
