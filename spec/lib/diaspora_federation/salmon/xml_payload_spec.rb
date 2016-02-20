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
      end

      context "returned object" do
        subject { Salmon::XmlPayload.unpack(Nokogiri::XML::Document.parse(entity_xml).root) }

        it "#to_h should match entity.to_h" do
          expect(subject.to_h).to eq(entity.to_h)
        end

        it "returns an entity instance of the original class" do
          expect(subject).to be_an_instance_of Entities::TestEntity
          expect(subject.test).to eq("asdf")
        end

        it "allows unwrapped entities" do
          xml = <<-XML
<test_entity>
  <test>asdf</test>
</test_entity>
XML

          entity = Salmon::XmlPayload.unpack(Nokogiri::XML::Document.parse(xml).root)

          expect(entity).to be_an_instance_of Entities::TestEntity
          expect(entity.test).to eq("asdf")
        end
      end
    end
  end
end
