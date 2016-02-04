module DiasporaFederation
  describe Salmon::XmlPayload do
    let(:entity) { Entities::TestEntity.new(test: "asdf") }
    let(:payload) { Salmon::XmlPayload.pack(entity) }
    let(:entity_xml) {
      <<-XML.strip
<XML>
  <post>
    <test_entity>
      <test>asdf</test>
    </test_entity>
  </post>
</XML>
XML
    }

    describe ".pack" do
      it "expects an Entity as param" do
        expect {
          Salmon::XmlPayload.pack(entity)
        }.not_to raise_error
      end

      it "raises an error when the param is not an Entity" do
        ["asdf", 1234, true, :test, payload].each do |val|
          expect {
            Salmon::XmlPayload.pack(val)
          }.to raise_error ArgumentError
        end
      end

      context "returned xml" do
        subject { Salmon::XmlPayload.pack(entity) }

        it "returns an xml wrapper" do
          expect(subject).to be_an_instance_of Nokogiri::XML::Element
          expect(subject.name).to eq("XML")
          expect(subject.children).to have(1).item
          expect(subject.children[0].name).to eq("post")
          expect(subject.children[0].children).to have(1).item
        end

        it "returns the entity xml inside the wrapper" do
          expect(subject.children[0].children[0].name).to eq("test_entity")
          expect(subject.children[0].children[0].children).to have(1).item
        end

        it "produces the expected XML" do
          expect(subject.to_xml).to eq(entity_xml)
        end
      end
    end

    describe ".unpack" do
      context "sanity" do
        it "expects an Nokogiri::XML::Element as param" do
          expect {
            Salmon::XmlPayload.unpack(payload)
          }.not_to raise_error
        end

        it "raises and error when the param is not an Nokogiri::XML::Element" do
          ["asdf", 1234, true, :test, entity].each do |val|
            expect {
              Salmon::XmlPayload.unpack(val)
            }.to raise_error ArgumentError, "only Nokogiri::XML::Element allowed"
          end
        end

        it "raises an error when the xml is wrong" do
          xml = <<-XML
<XML>
  <post>
    <unknown_entity>
      <test>asdf</test>
    </test_entity>
  </post>
</XML>
XML
          expect {
            Salmon::XmlPayload.unpack(Nokogiri::XML::Document.parse(xml).root)
          }.to raise_error Salmon::UnknownEntity, "'UnknownEntity' not found"
        end

        it "raises an error when the entity is not found" do
          xml = <<-XML
<root>
  <weird/>
</root>
XML
          expect {
            Salmon::XmlPayload.unpack(Nokogiri::XML::Document.parse(xml).root)
          }.to raise_error Salmon::InvalidStructure
        end
      end

      context "returned object" do
        subject { Salmon::XmlPayload.unpack(payload) }

        it "#to_h should match entity.to_h" do
          expect(subject.to_h).to eq(entity.to_h)
        end

        it "returns an entity instance of the original class" do
          expect(subject).to be_an_instance_of Entities::TestEntity
          expect(subject.test).to eq("asdf")
        end
      end

      context "parsing" do
        it "uses xml_name for parsing" do
          xml = <<-XML.strip
<XML>
  <post>
    <test_entity_with_xml_name>
      <test>asdf</test>
      <asdf>qwer</asdf>
    </test_entity>
  </post>
</XML>
XML
          entity = Salmon::XmlPayload.unpack(Nokogiri::XML::Document.parse(xml).root)

          expect(entity).to be_an_instance_of Entities::TestEntityWithXmlName
          expect(entity.test).to eq("asdf")
          expect(entity.qwer).to eq("qwer")
        end

        it "allows name for parsing even when property has a xml_name" do
          xml = <<-XML.strip
<XML>
  <post>
    <test_entity_with_xml_name>
      <test>asdf</test>
      <qwer>qwer</qwer>
    </test_entity>
  </post>
</XML>
XML
          entity = Salmon::XmlPayload.unpack(Nokogiri::XML::Document.parse(xml).root)

          expect(entity).to be_an_instance_of Entities::TestEntityWithXmlName
          expect(entity.test).to eq("asdf")
          expect(entity.qwer).to eq("qwer")
        end

        it "doesn't drop unknown properties" do
          xml = <<-XML
<XML>
  <post>
    <test_entity>
      <a_prop_from_newer_diaspora_version>some value</a_prop_from_newer_diaspora_version>
      <test>asdf</test>
      <some_random_property>another value</some_random_property>
    </test_entity>
  </post>
</XML>
XML

          entity = Salmon::XmlPayload.unpack(Nokogiri::XML::Document.parse(xml).root)

          expect(entity).to be_an_instance_of Entities::TestEntity
          expect(entity.test).to eq("asdf")
          expect(entity.additional_xml_elements).to eq(
            "a_prop_from_newer_diaspora_version" => "some value",
            "some_random_property"               => "another value"
          )
        end

        it "creates Entity with nil 'additional_xml_elements' if the xml has only known properties" do
          entity = Salmon::XmlPayload.unpack(Nokogiri::XML::Document.parse(entity_xml).root)

          expect(entity).to be_an_instance_of Entities::TestEntity
          expect(entity.test).to eq("asdf")
          expect(entity.additional_xml_elements).to be_nil
        end
      end

      context "relayable signature verification feature support" do
        it "calls signatures verification on relayable unpack" do
          entity = FactoryGirl.build(:comment_entity, diaspora_id: alice.diaspora_id)
          payload = Salmon::XmlPayload.pack(entity)
          payload.at_xpath("post/*[1]/author_signature").content = nil

          expect {
            Salmon::XmlPayload.unpack(payload)
          }.to raise_error DiasporaFederation::Entities::Relayable::SignatureVerificationFailed
        end
      end

      context "nested entities" do
        let(:child_entity1) { Entities::TestEntity.new(test: "bla") }
        let(:child_entity2) { Entities::OtherEntity.new(asdf: "blabla") }
        let(:nested_entity) {
          Entities::TestNestedEntity.new(asdf:  "QWERT",
                                         test:  child_entity1,
                                         multi: [child_entity2, child_entity2])
        }
        let(:nested_payload) { Salmon::XmlPayload.pack(nested_entity) }

        it "parses the xml with all the nested data" do
          entity = Salmon::XmlPayload.unpack(nested_payload)
          expect(entity.test.to_h).to eq(child_entity1.to_h)
          expect(entity.multi).to have(2).items
          expect(entity.multi.first.to_h).to eq(child_entity2.to_h)
          expect(entity.asdf).to eq("QWERT")
        end
      end
    end

    describe ".entity_class_name" do
      it "should parse a single word" do
        expect(Salmon::XmlPayload.send(:entity_class_name, "entity")).to eq("Entity")
      end

      it "should parse with underscore" do
        expect(Salmon::XmlPayload.send(:entity_class_name, "test_entity")).to eq("TestEntity")
      end

      it "raises an error when the entity name contains special characters" do
        expect {
          Salmon::XmlPayload.send(:entity_class_name, "te.st-enti/ty")
        }.to raise_error Salmon::InvalidEntityName, "'te.st-enti/ty' is invalid"
      end

      it "raises an error when the entity name contains upper case letters" do
        expect {
          Salmon::XmlPayload.send(:entity_class_name, "TestEntity")
        }.to raise_error Salmon::InvalidEntityName, "'TestEntity' is invalid"
      end

      it "raises an error when the entity name contains numbers" do
        expect {
          Salmon::XmlPayload.send(:entity_class_name, "te5t_ent1ty_w1th_number5")
        }.to raise_error Salmon::InvalidEntityName, "'te5t_ent1ty_w1th_number5' is invalid"
      end
    end
  end
end
