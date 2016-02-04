module DiasporaFederation
  describe PropertiesDSL do
    subject(:dsl) { Class.new.extend(PropertiesDSL) }

    context "simple properties" do
      it "can name simple properties by symbol" do
        dsl.property :test
        properties = dsl.class_props
        expect(properties).to have(1).item
        expect(properties.first[:name]).to eq(:test)
        expect(properties.first[:xml_name]).to eq(:test)
        expect(properties.first[:type]).to eq(String)
      end

      it "will not accept other types for names" do
        ["test", 1234, true, {}].each do |val|
          expect {
            dsl.property val
          }.to raise_error PropertiesDSL::InvalidName
        end
      end

      it "can define multiple properties" do
        dsl.property :test
        dsl.property :asdf
        dsl.property :zzzz
        properties = dsl.class_props
        expect(properties).to have(3).items
        expect(properties.map {|e| e[:name] }).to include(:test, :asdf, :zzzz)
        expect(properties.map {|e| e[:xml_name] }).to include(:test, :asdf, :zzzz)
        properties.each {|e| expect(e[:type]).to eq(String) }
      end

      it "can add an xml name to simple properties with a symbol" do
        dsl.property :test, xml_name: :xml_test
        properties = dsl.class_props
        expect(properties).to have(1).item
        expect(properties.first[:name]).to eq(:test)
        expect(properties.first[:xml_name]).to eq(:xml_test)
        expect(properties.first[:type]).to eq(String)
      end

      it "will not accept other types for xml names" do
        ["test", 1234, true, {}].each do |val|
          expect {
            dsl.property :test, xml_name: val
          }.to raise_error PropertiesDSL::InvalidName, "invalid xml_name"
        end
      end
    end

    context "nested entities" do
      it "gets included in the properties" do
        expect(Entities::TestNestedEntity.class_prop_names).to include(:test, :multi)
      end

      it "can define nested entities" do
        dsl.entity :other, Entities::TestEntity
        properties = dsl.class_props
        expect(properties).to have(1).item
        expect(properties.first[:name]).to eq(:other)
        expect(properties.first[:type]).to eq(Entities::TestEntity)
      end

      it "can define an array of a nested entity" do
        dsl.entity :other, [Entities::TestEntity]
        properties = dsl.class_props
        expect(properties).to have(1).item
        expect(properties.first[:name]).to eq(:other)
        expect(properties.first[:type]).to be_an_instance_of(Array)
        expect(properties.first[:type].first).to eq(Entities::TestEntity)
      end

      it "must be an entity subclass" do
        [1234, true, {}].each do |val|
          expect {
            dsl.entity :fail, val
          }.to raise_error PropertiesDSL::InvalidType
        end
      end

      it "must be an entity subclass for array" do
        [1234, true, {}].each do |val|
          expect {
            dsl.entity :fail, [val]
          }.to raise_error PropertiesDSL::InvalidType
        end
      end

      it "can not add an xml name to a nested entity" do
        expect {
          dsl.entity :other, Entities::TestEntity, xml_name: :other_name
        }.to raise_error ArgumentError, "xml_name is not supported for nested entities"
      end
    end

    describe ".default_values" do
      it "can accept default values" do
        dsl.property :test, default: :foobar
        defaults = dsl.default_values
        expect(defaults[:test]).to eq(:foobar)
      end

      it "can accept default blocks" do
        dsl.property :test, default: -> { "default" }
        defaults = dsl.default_values
        expect(defaults[:test]).to eq("default")
      end
    end

    describe ".nested_class_props" do
      it "returns the definition of nested class properties in an array" do
        n_props = Entities::TestNestedEntity.nested_class_props
        expect(n_props).to be_an_instance_of(Array)
        expect(n_props.map {|p| p[:name] }).to include(:test, :multi)
        expect(n_props.map {|p| p[:type] }).to include(Entities::TestEntity, [Entities::OtherEntity])
      end
    end

    describe ".class_prop_names" do
      it "returns the names of all class props in an array" do
        expect(Entities::TestDefaultEntity.class_prop_names).to be_an_instance_of(Array)
        expect(Entities::TestDefaultEntity.class_prop_names).to include(:test1, :test2, :test3, :test4)
      end
    end

    describe ".find_property_for_xml_name" do
      it "finds property by xml_name" do
        dsl.property :test, xml_name: :xml_test
        expect(dsl.find_property_for_xml_name("xml_test")).to eq(dsl.class_props.first)
      end

      it "finds property by name" do
        dsl.property :test, xml_name: :xml_test
        expect(dsl.find_property_for_xml_name("test")).to eq(dsl.class_props.first)
      end

      it "returns nil if property is not defined" do
        dsl.property :test, xml_name: :xml_test
        expect(dsl.find_property_for_xml_name("unknown")).to be_nil
      end
    end
  end
end
