describe Validation::Rule::Birthday do
  it "will not accept parameters" do
    validator = Validation::Validator.new({})
    expect {
      validator.rule(:birthday, birthday: {param: true})
    }.to raise_error ArgumentError
  end

  it "has an error key" do
    expect(described_class.new.error_key).to eq(:birthday)
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

    it "allows nil and empty" do
      [nil, ""].each do |val|
        validator = Validation::Validator.new(OpenStruct.new(birthday: val))
        validator.rule(:birthday, :birthday)

        expect(validator).to be_valid
        expect(validator.errors).to be_empty
      end
    end

    it "fails for invalid date string" do
      validator = Validation::Validator.new(OpenStruct.new(birthday: "i'm no date"))
      validator.rule(:birthday, :birthday)

      expect(validator).not_to be_valid
      expect(validator.errors).to include(:birthday)
    end
  end
end
