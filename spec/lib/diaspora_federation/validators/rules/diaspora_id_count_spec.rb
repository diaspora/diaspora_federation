describe Validation::Rule::DiasporaIdCount do
  let(:id_str) { 3.times.map { FactoryGirl.generate(:diaspora_id) }.join(";") }

  it "requires a parameter" do
    validator = Validation::Validator.new({})
    expect {
      validator.rule(:ids, :diaspora_id_count)
    }.to raise_error ArgumentError
  end

  it "requires a integer as parameter" do
    validator = Validation::Validator.new({})
    [nil, "", 5.5].each do |val|
      expect {
        validator.rule(:ids, diaspora_id_count: {maximum: val})
      }.to raise_error ArgumentError, "A number has to be specified for :maximum"
    end
  end

  it "has an error key" do
    expect(described_class.new(maximum: 5).error_key).to eq(:diaspora_id_count)
  end

  context "validation" do
    it "validates less ids" do
      validator = Validation::Validator.new(OpenStruct.new(ids: id_str))
      validator.rule(:ids, diaspora_id_count: {maximum: 5})

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "fails for less but non ids" do
      bad_str = "user@example.com;i am a weird diaspora id @@@ ### 12345;shouldnt be reached by a rule"
      validator = Validation::Validator.new(OpenStruct.new(ids: bad_str))
      validator.rule(:ids, diaspora_id_count: {maximum: 5})

      expect(validator).not_to be_valid
      expect(validator.errors).to include(:ids)
    end

    it "validates exactly as many ids" do
      validator = Validation::Validator.new(OpenStruct.new(ids: id_str))
      validator.rule(:ids, diaspora_id_count: {maximum: 3})

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end

    it "fails for too many ids" do
      validator = Validation::Validator.new(OpenStruct.new(ids: id_str))
      validator.rule(:ids, diaspora_id_count: {maximum: 1})

      expect(validator).not_to be_valid
      expect(validator.errors).to include(:ids)
    end
  end
end
