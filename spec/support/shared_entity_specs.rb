shared_examples "an Entity subclass" do
  it "should be an Entity" do
    expect(described_class).to be < DiasporaFederation::Entity
  end

  it "has its properties set" do
    expect(described_class.class_prop_names).to include(*data.keys)
  end

  context "behaviour" do
    let(:instance) { described_class.new(data) }

    describe "initialize" do
      it "must not create blank instances" do
        expect { described_class.new({}) }.to raise_error ArgumentError
      end

      it "fails if nil was given" do
        expect { described_class.new(nil) }.to raise_error ArgumentError, "expected a Hash"
      end

      it "should be frozen" do
        expect(instance).to be_frozen
      end
    end

    describe "#to_h" do
      it "should resemble the input data" do
        expect(instance.to_h).to eq(data)
      end
    end
  end
end

shared_examples "an XML Entity" do
  let(:instance) { described_class.new(data) }

  describe "#to_xml" do
    it "produces correct XML" do
      expect(instance.to_xml.to_s.strip).to eq(xml.strip)
    end
  end

  context "parsing" do
    it "reads its own output" do
      packed_xml = DiasporaFederation::Salmon::XmlPayload.pack(instance)
      parsed_instance = DiasporaFederation::Salmon::XmlPayload.unpack(packed_xml)

      check_entity(instance, parsed_instance)
    end
  end

  def check_entity(entity, parsed_entity)
    entity.class.class_props.each do |prop_def|
      name = prop_def[:name]

      validate_values(entity.send(name), parsed_entity.send(name), prop_def[:type])
    end
  end

  def validate_values(value, parsed_value, type)
    if value.nil?
      expect(parsed_value).to be_nil
    elsif type == String
      expect(parsed_value).to eq(value.to_s)
    elsif type.instance_of?(Array)
      value.each_with_index {|entity, index| check_entity(entity, parsed_value[index]) }
    elsif type.ancestors.include?(DiasporaFederation::Entity)
      check_entity(value, parsed_value)
    end
  end
end

shared_examples "a relayable Entity" do
  let(:instance) { described_class.new(data.merge(author_signature: nil, parent_author_signature: nil)) }

  context "signatures generation" do
    def verify_signature(pubkey, signature, signed_string)
      pubkey.verify(OpenSSL::Digest::SHA256.new, Base64.decode64(signature), signed_string)
    end

    it "computes correct signatures for the entity" do
      signed_string = described_class::LEGACY_SIGNATURE_ORDER.map {|name| data[name] }.join(";")

      xml = DiasporaFederation::Salmon::XmlPayload.pack(instance)

      author_signature = xml.at_xpath("post/*[1]/author_signature").text
      parent_author_signature = xml.at_xpath("post/*[1]/parent_author_signature").text

      alice_public_key = OpenSSL::PKey::RSA.new(alice.serialized_public_key)
      bob_public_key = OpenSSL::PKey::RSA.new(bob.serialized_public_key)
      expect(verify_signature(alice_public_key, author_signature, signed_string)).to be_truthy
      expect(verify_signature(bob_public_key, parent_author_signature, signed_string)).to be_truthy
    end
  end
end
