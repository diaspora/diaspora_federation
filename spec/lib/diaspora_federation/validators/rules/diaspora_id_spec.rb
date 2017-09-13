describe Validation::Rule::DiasporaId do
  it "will not accept parameters" do
    validator = Validation::Validator.new({})
    expect {
      validator.rule(:diaspora_id, diaspora_id: {param: true})
    }.to raise_error ArgumentError
  end

  it "has an error key" do
    expect(described_class.new.error_key).to eq(:diaspora_id)
  end

  context "validation" do
    it "validates a normal diaspora* ID" do
      validator = Validation::Validator.new(OpenStruct.new(diaspora_id: "some_user@example.com"))
      validator.rule(:diaspora_id, :diaspora_id)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "validates a diaspora* ID with localhost" do
      validator = Validation::Validator.new(OpenStruct.new(diaspora_id: "some_user@localhost"))
      validator.rule(:diaspora_id, :diaspora_id)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "validates a diaspora* ID with port" do
      validator = Validation::Validator.new(OpenStruct.new(diaspora_id: "some_user@example.com:3000"))
      validator.rule(:diaspora_id, :diaspora_id)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "validates a diaspora* ID with IPv4 address" do
      validator = Validation::Validator.new(OpenStruct.new(diaspora_id: "some_user@123.45.67.89"))
      validator.rule(:diaspora_id, :diaspora_id)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "validates a diaspora* ID with IPv6 address" do
      validator = Validation::Validator.new(OpenStruct.new(diaspora_id: "some_user@[2001:1234:5678:90ab:cdef::1]"))
      validator.rule(:diaspora_id, :diaspora_id)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "validates a diaspora* ID with . and -" do
      validator = Validation::Validator.new(OpenStruct.new(diaspora_id: "some-fancy.user@example.com"))
      validator.rule(:diaspora_id, :diaspora_id)

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "fails if the diaspora* ID contains a / in the domain-name" do
      validator = Validation::Validator.new(OpenStruct.new(diaspora_id: "some_user@example.com/friendica"))
      validator.rule(:diaspora_id, :diaspora_id)

      expect(validator).not_to be_valid
      expect(validator.errors).to include(:diaspora_id)
    end

    it "fails if the diaspora* ID contains a _ in the domain-name" do
      validator = Validation::Validator.new(OpenStruct.new(diaspora_id: "some_user@invalid_domain.com"))
      validator.rule(:diaspora_id, :diaspora_id)

      expect(validator).not_to be_valid
      expect(validator.errors).to include(:diaspora_id)
    end

    it "fails if the diaspora* ID contains a special-chars in the username" do
      validator = Validation::Validator.new(OpenStruct.new(diaspora_id: "some_user$^%@example.com"))
      validator.rule(:diaspora_id, :diaspora_id)

      expect(validator).not_to be_valid
      expect(validator.errors).to include(:diaspora_id)
    end

    it "fails for nil and empty" do
      [nil, ""].each do |val|
        validator = Validation::Validator.new(OpenStruct.new(diaspora_id: val))
        validator.rule(:diaspora_id, :diaspora_id)

        expect(validator).not_to be_valid
        expect(validator.errors).to include(:diaspora_id)
      end
    end
  end
end
