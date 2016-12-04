shared_examples "an Entity subclass" do
  it "should be an Entity" do
    expect(described_class).to be < DiasporaFederation::Entity
  end

  it "has its properties set" do
    expect(described_class.class_props.keys).to include(*data.keys)
  end

  context "behaviour" do
    let(:instance) { described_class.new(data) }

    describe "initialize" do
      it "must not create blank instances" do
        expect { described_class.new({}) }.to raise_error DiasporaFederation::Entity::ValidationError
      end

      it "fails if nil was given" do
        expect { described_class.new(nil) }.to raise_error ArgumentError, "expected a Hash"
      end

      it "should be frozen" do
        expect(instance).to be_frozen
      end
    end

    describe "#unfold" do
      it "should return a hash with nested data" do
        expected_data = data.map {|key, value|
          if [String, TrueClass, FalseClass, Integer, Time, NilClass].any? {|c| value.is_a? c }
            [key, value]
          elsif value.instance_of?(Array)
            [key, value.map {|element| element.send(:unfold) }]
          else
            [key, value.send(:unfold)]
          end
        }.to_h

        expect(instance.send(:unfold)).to eq(expected_data)
      end
    end

    describe "#to_s" do
      it "should represent the entity as string" do
        expect(instance.to_s).to eq(string)
      end
    end
  end
end

shared_examples "an XML Entity" do |ignored_props=[]|
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

      check_entity(instance, parsed_instance, ignored_props)
    end
  end

  def check_entity(entity, parsed_entity, ignored_props)
    entity.class.class_props.reject {|name| ignored_props.include?(name) }.each do |name, type|
      validate_values(entity.send(name), parsed_entity.send(name), type, ignored_props)
    end
  end

  def validate_values(value, parsed_value, type, ignored_props)
    if value.nil?
      expect(parsed_value).to be_nil
    elsif type == String
      expect(parsed_value.to_s).to eq(value.to_s)
    elsif type.instance_of?(Array)
      value.each_with_index {|entity, index| check_entity(entity, parsed_value[index], ignored_props) }
    elsif type.ancestors.include?(DiasporaFederation::Entity)
      check_entity(value, parsed_value, ignored_props)
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

      expect(verify_signature(alice.public_key, author_signature, signed_string)).to be_truthy
      expect(verify_signature(bob.public_key, parent_author_signature, signed_string)).to be_truthy
    end
  end
end

shared_examples "a retraction" do
  context "receive with no target found" do
    let(:unknown_guid) { FactoryGirl.generate(:guid) }
    let(:instance) { described_class.new(data.merge(target_guid: unknown_guid)) }

    it "raises when no target is found" do
      xml = instance.to_xml
      expect {
        described_class.from_xml(xml)
      }.to raise_error DiasporaFederation::Entities::Retraction::TargetNotFound,
                       "not found: #{data[:target_type]}:#{unknown_guid}"
    end
  end
end
