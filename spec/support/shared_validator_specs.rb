def entity_stub(entity, property, val=nil)
  instance = OpenStruct.new(FactoryGirl.attributes_for(entity))
  instance.public_send("#{property}=", val) unless val.nil?
  instance
end

shared_examples "a diaspora_id validator" do
  it "validates a well-formed diaspora_id" do
    validator = validator_class.new(entity_stub(entity, property))

    expect(validator).to be_valid
    expect(validator.errors).to be_empty
  end

  it "must not be empty" do
    validator = validator_class.new(entity_stub(entity, property, ""))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end

  it "must be a valid diaspora id" do
    validator = validator_class.new(entity_stub(entity, property, "i am a weird diaspora id @@@ ### 12345"))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end
end

shared_examples "a guid validator" do
  it "validates a well-formed guid" do
    validator = validator_class.new(entity_stub(entity, property))

    expect(validator).to be_valid
    expect(validator.errors).to be_empty
  end

  it "validates a well-formed guid from redmatrix" do
    validator = validator_class.new(entity_stub(entity, property, "1234567890ABCDefgh_ijkl-mnopQR@example.com:3000"))

    expect(validator).to be_valid
    expect(validator.errors).to be_empty
  end

  it "must be at least 16 chars" do
    validator = validator_class.new(entity_stub(entity, property, "aaaaaa"))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end

  it "must only contain [0-9a-z-_@.:]" do
    validator = validator_class.new(entity_stub(entity, property, "zzz+-#*$$"))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end

  it "must not be empty" do
    validator = validator_class.new(entity_stub(entity, property, ""))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end
end

shared_examples "a boolean validator" do
  it "validates a well-formed boolean" do
    [true, "true", false, "false"].each do |val|
      validator = validator_class.new(entity_stub(entity, property, val))

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end
  end

  it "must not be an arbitrary string or other object" do
    ["asdf", Time.zone.today, 1234].each do |val|
      validator = validator_class.new(entity_stub(entity, property, val))

      expect(validator).not_to be_valid
      expect(validator.errors).to include(property)
    end
  end
end
