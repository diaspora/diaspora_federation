def entity_stub(entity, property, val)
  instance = OpenStruct.new(FactoryGirl.attributes_for(entity))
  instance.public_send("#{property}=", val)
  instance
end

shared_examples "a diaspora id validator" do
  it "must not be nil or empty" do
    [nil, ""].each do |val|
      validator = described_class.new(entity_stub(entity, property, val))

      expect(validator).not_to be_valid
      expect(validator.errors).to include(property)
    end
  end

  it "must be a valid diaspora id" do
    validator = described_class.new(entity_stub(entity, property, "i am a weird diaspora id @@@ ### 12345"))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end
end

shared_examples "a guid validator" do
  it "validates a well-formed guid from redmatrix" do
    validator = described_class.new(entity_stub(entity, property, "1234567890ABCDefgh_ijkl-mnopQR@example.com:3000"))

    expect(validator).to be_valid
    expect(validator.errors).to be_empty
  end

  it "must be at least 16 chars" do
    validator = described_class.new(entity_stub(entity, property, "aaaaaa"))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end

  it "must only contain [0-9a-z-_@.:]" do
    validator = described_class.new(entity_stub(entity, property, "zzz+-#*$$"))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end

  it "must not be nil or empty" do
    [nil, ""].each do |val|
      validator = described_class.new(entity_stub(entity, property, val))

      expect(validator).not_to be_valid
      expect(validator.errors).to include(property)
    end
  end
end

shared_examples "a boolean validator" do
  it "validates a well-formed boolean" do
    [true, "true", false, "false"].each do |val|
      validator = described_class.new(entity_stub(entity, property, val))

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end
  end

  it "must not be an arbitrary string or other object" do
    ["asdf", Time.zone.today, 1234].each do |val|
      validator = described_class.new(entity_stub(entity, property, val))

      expect(validator).not_to be_valid
      expect(validator.errors).to include(property)
    end
  end
end

shared_examples "a public key validator" do
  it "fails for malformed rsa key" do
    validator = described_class.new(entity_stub(entity, property, "ASDF"))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end

  it "must not be nil or empty" do
    [nil, ""].each do |val|
      validator = described_class.new(entity_stub(entity, property, val))

      expect(validator).not_to be_valid
      expect(validator.errors).to include(property)
    end
  end
end

shared_examples "a name validator" do
  it "is allowed to be nil or empty" do
    [nil, ""].each do |val|
      validator = described_class.new(entity_stub(entity, property, val))

      expect(validator).to be_valid
      expect(validator.errors).to be_empty
    end
  end

  it "is allowed to contain special chars" do
    validator = described_class.new(entity_stub(entity, property, "cool name ©"))

    expect(validator).to be_valid
    expect(validator.errors).to be_empty
  end

  it "must not exceed 32 chars" do
    validator = described_class.new(entity_stub(entity, property, "abcdefghijklmnopqrstuvwxyz_aaaaaaaaaa"))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end

  it "must not contain semicolons" do
    validator = described_class.new(entity_stub(entity, property, "asdf;qwer;yxcv"))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end
end

shared_examples "a url validator without path" do
  it "fails for url with special chars" do
    validator = described_class.new(entity_stub(entity, property, "https://asdf$%.com"))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end

  it "fails for url without scheme" do
    validator = described_class.new(entity_stub(entity, property, "example.com"))

    expect(validator).not_to be_valid
    expect(validator.errors).to include(property)
  end
end
