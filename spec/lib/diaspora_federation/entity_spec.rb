module DiasporaFederation
  describe Entity do
    let(:data) { {test1: "asdf", test2: 1234, test3: false, test4: false} }

    it "should extend Entity" do
      expect(Entities::TestDefaultEntity).to be < Entity
    end

    context "creation" do
      it "freezes the instance after initialization" do
        entity = Entities::TestDefaultEntity.new(data)
        expect(entity).to be_frozen
      end

      it "checks for required properties" do
        expect {
          Entities::TestDefaultEntity.new({})
        }.to raise_error Entity::ValidationError, "missing required properties: test1, test2"
      end

      context "defaults" do
        it "sets the defaults" do
          entity = Entities::TestDefaultEntity.new(test1: "1", test2: "2")
          expect(entity.test3).to be_truthy
        end

        it "handles callable defaults" do
          entity = Entities::TestDefaultEntity.new(test1: "1", test2: "2")
          expect(entity.test4).to be_truthy
        end

        it "uses provided values over defaults" do
          entity = Entities::TestDefaultEntity.new(data)
          expect(entity.test3).to be_falsey
          expect(entity.test4).to be_falsey
        end
      end

      it "sets nil if string is empty" do
        data[:test1] = ""
        entity = Entities::TestDefaultEntity.new(data)
        expect(entity.test1).to be_nil
      end

      context "validation" do
        let(:invalid_data) { {test1: "as;df", test2: nil, test3: "no boolean"} }

        it "validates the entity and raise an error with failed properties if not valid" do
          expect {
            Entities::TestDefaultEntity.new(invalid_data)
          }.to raise_error Entity::ValidationError, /Failed validation for properties:.*test1.*\|.*test2.*\|.*test3/
        end

        it "contains the failed rule" do
          expect {
            Entities::TestDefaultEntity.new(invalid_data)
          }.to raise_error Entity::ValidationError, /property: test2, value: nil, rule: not_nil, with params: \{\}/
        end

        it "contains the params of the failed rule" do
          expect {
            Entities::TestDefaultEntity.new(invalid_data)
          }.to raise_error Entity::ValidationError, /rule: regular_expression, with params: \{:regex=>.*\}/
        end
      end
    end

    describe "#to_h" do
      it "returns a hash of the internal data" do
        entity = Entities::TestDefaultEntity.new(data)
        expect(entity.to_h).to eq(data.transform_values(&:to_s))
      end
    end

    describe "#to_xml" do
      it "returns an Nokogiri::XML::Element" do
        entity = Entities::TestDefaultEntity.new(data)
        expect(entity.to_xml).to be_an_instance_of Nokogiri::XML::Element
      end

      it "has the root node named after the class (underscored)" do
        entity = Entities::TestDefaultEntity.new(data)
        expect(entity.to_xml.name).to eq("test_default_entity")
      end

      it "contains nodes for each of the properties" do
        entity = Entities::TestDefaultEntity.new(data)
        xml_children = entity.to_xml.children
        expect(xml_children).to have_exactly(4).items
        xml_children.each do |node|
          expect(%w(test1 test2 test3 test4)).to include(node.name)
        end
      end

      it "replaces invalid XML characters" do
        entity = Entities::TestEntity.new(test: "asdfasdf asdf💩asdf\nasdf")
        xml = entity.to_xml.to_xml
        parsed = Entities::TestEntity.from_xml(Nokogiri::XML::Document.parse(xml).root).test
        expect(parsed).to eq("asdf�asdf asdf💩asdf\nasdf")
      end
    end

    describe ".from_xml" do
      let(:entity) { Entities::TestEntity.new(test: "asdf") }
      let(:entity_xml) { entity.to_xml }

      context "sanity" do
        it "expects an Nokogiri::XML::Element as param" do
          expect {
            Entities::TestEntity.from_xml(entity_xml)
          }.not_to raise_error
        end

        it "raises and error when the param is not an Nokogiri::XML::Element" do
          ["asdf", 1234, true, :test, entity].each do |val|
            expect {
              Entity.from_xml(val)
            }.to raise_error ArgumentError, "only Nokogiri::XML::Element allowed"
          end
        end

        it "raises an error when the entity class doesn't match the root node" do
          xml = <<-XML
<unknown_entity>
  <test>asdf</test>
</unknown_entity>
XML

          expect {
            Entity.from_xml(Nokogiri::XML::Document.parse(xml).root)
          }.to raise_error Entity::InvalidRootNode, "'unknown_entity' can't be parsed by DiasporaFederation::Entity"
        end
      end

      context "returned object" do
        subject { Entities::TestEntity.from_xml(entity_xml) }

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
<test_entity_with_xml_name>
  <test>asdf</test>
  <asdf>qwer</asdf>
</test_entity_with_xml_name>
XML

          entity = Entities::TestEntityWithXmlName.from_xml(Nokogiri::XML::Document.parse(xml).root)

          expect(entity).to be_an_instance_of Entities::TestEntityWithXmlName
          expect(entity.test).to eq("asdf")
          expect(entity.qwer).to eq("qwer")
        end

        it "allows name for parsing even when property has a xml_name" do
          xml = <<-XML.strip
<test_entity_with_xml_name>
  <test>asdf</test>
  <qwer>qwer</qwer>
</test_entity_with_xml_name>
XML

          entity = Entities::TestEntityWithXmlName.from_xml(Nokogiri::XML::Document.parse(xml).root)

          expect(entity).to be_an_instance_of Entities::TestEntityWithXmlName
          expect(entity.test).to eq("asdf")
          expect(entity.qwer).to eq("qwer")
        end

        it "parses the string to the correct type" do
          xml = <<-XML.strip
<test_default_entity>
  <test1>asdf</test1>
  <test2>qwer</qwer2>
  <test3>true</qwer3>
</test_default_entity>
XML

          entity = Entities::TestDefaultEntity.from_xml(Nokogiri::XML::Document.parse(xml).root)

          expect(entity).to be_an_instance_of Entities::TestDefaultEntity
          expect(entity.test1).to eq("asdf")
          expect(entity.test2).to eq("qwer")
          expect(entity.test3).to eq(true)
        end

        it "parses boolean fields with false value" do
          xml = <<-XML.strip
<test_entity_with_boolean>
  <test>false</test>
</test_entity_with_boolean>
XML

          entity = Entities::TestEntityWithBoolean.from_xml(Nokogiri::XML::Document.parse(xml).root)
          expect(entity).to be_an_instance_of Entities::TestEntityWithBoolean
          expect(entity.test).to eq(false)
        end

        it "parses boolean fields with a randomly matching pattern as erroneous" do
          %w(ttFFFtt yesFFDSFSDy noDFDSFFDFn fXf LLyes).each do |weird_value|
            xml = <<-XML.strip
<test_entity_with_boolean>
  <test>#{weird_value}</test>
</test_entity_with_boolean>
XML

            expect {
              Entities::TestEntityWithBoolean.from_xml(Nokogiri::XML::Document.parse(xml).root)
            }.to raise_error Entity::ValidationError, "missing required properties: test"
          end
        end

        it "parses integer fields with a randomly matching pattern as erroneous" do
          %w(1,2,3 foobar two).each do |weird_value|
            xml = <<-XML.strip
<test_entity_with_integer>
  <test>#{weird_value}</test>
</test_entity_with_integer>
XML

            expect {
              Entities::TestEntityWithInteger.from_xml(Nokogiri::XML::Document.parse(xml).root)
            }.to raise_error Entity::ValidationError, "missing required properties: test"
          end
        end

        it "parses timestamp fields with a randomly matching pattern as erroneous" do
          %w(foobar yesterday now 1.2.foo).each do |weird_value|
            xml = <<-XML.strip
<test_entity_with_timestamp>
  <test>#{weird_value}</test>
</test_entity_with_timestamp>
XML

            expect {
              Entities::TestEntityWithTimestamp.from_xml(Nokogiri::XML::Document.parse(xml).root)
            }.to raise_error Entity::ValidationError, "missing required properties: test"
          end
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
        let(:nested_payload) { nested_entity.to_xml }

        it "parses the xml with all the nested data" do
          entity = Entities::TestNestedEntity.from_xml(nested_payload)
          expect(entity.test.to_h).to eq(child_entity1.to_h)
          expect(entity.multi).to have(2).items
          expect(entity.multi.first.to_h).to eq(child_entity2.to_h)
          expect(entity.asdf).to eq("QWERT")
        end
      end
    end

    describe ".entity_name" do
      it "strips the module and returns the name underscored" do
        expect(Entities::TestDefaultEntity.entity_name).to eq("test_default_entity")
        expect(Entities::TestNestedEntity.entity_name).to eq("test_nested_entity")
        expect(Entities::OtherEntity.entity_name).to eq("other_entity")
      end

      it "works with a single word" do
        expect(Entities::Entity.entity_name).to eq("entity")
      end
    end

    describe ".entity_class" do
      it "should parse a single word" do
        expect(Entity.entity_class("entity")).to eq(Entities::Entity)
      end

      it "should parse with underscore" do
        expect(Entity.entity_class("test_entity")).to eq(Entities::TestEntity)
      end

      it "should not change the input string" do
        entity_name = "test_entity"
        Entity.entity_class(entity_name)
        expect(entity_name).to eq("test_entity")
      end

      it "raises an error when the entity name contains special characters" do
        expect {
          Entity.entity_class("te.st-enti/ty")
        }.to raise_error Entity::InvalidEntityName, "'te.st-enti/ty' is invalid"
      end

      it "raises an error when the entity name contains upper case letters" do
        expect {
          Entity.entity_class("TestEntity")
        }.to raise_error Entity::InvalidEntityName, "'TestEntity' is invalid"
      end

      it "raises an error when the entity name contains numbers" do
        expect {
          Entity.entity_class("te5t_ent1ty_w1th_number5")
        }.to raise_error Entity::InvalidEntityName, "'te5t_ent1ty_w1th_number5' is invalid"
      end

      it "raises an error when the entity is unknown" do
        expect {
          Entity.entity_class("unknown_entity")
        }.to raise_error Entity::UnknownEntity, "'UnknownEntity' not found"
      end
    end

    context "nested entities" do
      let(:nested_data) {
        {
          asdf:  "FDSA",
          test:  Entities::TestEntity.new(test: "test"),
          multi: [Entities::OtherEntity.new(asdf: "asdf"), Entities::OtherEntity.new(asdf: "asdf")]
        }
      }
      let(:nested_hash) {
        {
          asdf:  nested_data[:asdf],
          test:  nested_data[:test].to_h,
          multi: nested_data[:multi].map(&:to_h)
        }
      }

      it "gets returned as Hash by #to_h" do
        entity = Entities::TestNestedEntity.new(nested_data)

        expect(entity.to_h).to eq(nested_hash)
      end

      it "gets xml-ified by #to_xml" do
        entity = Entities::TestNestedEntity.new(nested_data)
        xml = entity.to_xml
        expect(xml.children).to have_exactly(4).items
        xml.children.each do |node|
          expect(%w(asdf test_entity other_entity)).to include(node.name)
        end
        expect(xml.xpath("test_entity")).to have_exactly(1).items
        expect(xml.xpath("other_entity")).to have_exactly(2).items
      end

      it "is not added to xml if #to_xml returns nil" do
        entity = Entities::TestEntityWithRelatedEntity.new(test: "test", parent: FactoryGirl.build(:related_entity))
        xml = entity.to_xml
        expect(xml.children).to have_exactly(1).items
        xml.children.first.name = "test"
      end

      it "instantiates nested entities if provided as hash" do
        entity = Entities::TestNestedEntity.new(nested_hash)

        expect(entity.test).to be_instance_of(Entities::TestEntity)
        expect(entity.test.test).to eq("test")

        expect(entity.multi).to be_instance_of(Array)
        expect(entity.multi).to have_exactly(2).items
        expect(entity.multi.first).to be_instance_of(Entities::OtherEntity)
        expect(entity.multi.first.asdf).to eq("asdf")
      end

      it "handles empty xml-element for nested entities" do
        xml = <<-XML
<test_nested_entity>
  <asdf>FDSA</asdf>
  <test_entity/>
  <other_entity/>
</test_nested_entity>
XML

        entity = Entities::TestNestedEntity.from_xml(Nokogiri::XML::Document.parse(xml).root)

        expect(entity.asdf).to eq("FDSA")
        expect(entity.test).to be_nil
        expect(entity.multi).to be_empty
      end
    end

    context "xml_name" do
      let(:hash) { {test: "test", qwer: "qwer"} }

      it "uses xml_name for the #to_xml" do
        entity = Entities::TestEntityWithXmlName.new(hash)
        xml_children = entity.to_xml.children
        expect(xml_children).to have_exactly(2).items
        xml_children.each do |node|
          expect(%w(test asdf)).to include(node.name)
        end
      end

      it "should not use the xml_name for the #to_h" do
        entity = Entities::TestEntityWithXmlName.new(hash)
        expect(entity.to_h).to eq(hash)
      end
    end
  end
end
