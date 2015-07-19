describe Validation::Rule::Birthday do
  it "will not accept parameters" do
    validator = Validation::Validator.new({})
    expect {
      validator.rule(:birthday, birthday: {param: true})
    }.to raise_error ArgumentError
  end

  context "validation" do
    it "validates a date object" do
      validator = Validation::Validator.new(OpenStruct.new(birthday: Date.new))
      validator.rule(:birthday, :birthday)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "validates a string" do
      validator = Validation::Validator.new(OpenStruct.new(birthday: "2015-07-19"))
      validator.rule(:birthday, :birthday)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "validates an empty string" do
      validator = Validation::Validator.new(OpenStruct.new(birthday: ""))
      validator.rule(:birthday, :birthday)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "validates nil" do
      validator = Validation::Validator.new(OpenStruct.new(birthday: nil))
      validator.rule(:birthday, :birthday)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "fails for invalid date string" do
      validator = Validation::Validator.new(OpenStruct.new(birthday: "i'm no date"))
      validator.rule(:birthday, :birthday)

      expect(validator).not_to be_valid
      expect(validator.errors).to include(:birthday)
    end
  end
end
