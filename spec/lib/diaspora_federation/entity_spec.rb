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
        }.to raise_error ArgumentError, "missing required properties: test1, test2"
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
        expect(entity.to_h).to eq(data)
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
    end

    describe ".entity_name" do
      it "strips the module and returns the name underscored" do
        expect(Entities::TestDefaultEntity.entity_name).to eq("test_default_entity")
        expect(Entities::TestNestedEntity.entity_name).to eq("test_nested_entity")
        expect(Entities::OtherEntity.entity_name).to eq("other_entity")
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

      it "gets returned by #to_h" do
        entity = Entities::TestNestedEntity.new(nested_data)
        expect(entity.to_h).to eq(nested_data)
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
