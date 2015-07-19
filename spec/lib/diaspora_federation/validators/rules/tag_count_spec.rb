describe Validation::Rule::TagCount do
  it "requires a parameter" do
    validator = Validation::Validator.new({})
    expect {
      validator.rule(:tags, :tag_count)
    }.to raise_error ArgumentError
  end

  context "validation" do
    let(:tag_str) { "#i #love #tags" }

    it "validates less tags" do
      validator = Validation::Validator.new(OpenStruct.new(tags: tag_str))
      validator.rule(:tags, tag_count: {maximum: 5})

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "validates exactly as many tags" do
      validator = Validation::Validator.new(OpenStruct.new(tags: tag_str))
      validator.rule(:tags, tag_count: {maximum: 3})

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "fails for too many tags" do
      validator = Validation::Validator.new(OpenStruct.new(tags: tag_str))
      validator.rule(:tags, tag_count: {maximum: 1})

      expect(validator).not_to be_valid
      expect(validator.errors).to include(:tags)
    end
  end
end
