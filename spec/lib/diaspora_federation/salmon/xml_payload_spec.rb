module DiasporaFederation
  describe Salmon::XmlPayload do
    let(:entity) { Entities::TestEntity.new(test: "asdf") }
    let(:entity_xml) { <<-XML.strip }
<XML>
  <post>
    <test_entity>
      <test>asdf</test>
    </test_entity>
  </post>
</XML>
XML

    describe ".unpack" do
      context "sanity" do
        it "expects an Nokogiri::XML::Element as param" do
          expect {
            Salmon::XmlPayload.unpack(Nokogiri::XML::Document.parse(entity_xml).root)
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
