module DiasporaFederation
  describe Entities::Participation do
    let(:parent) { FactoryGirl.create(:post, author: bob) }
    let(:parent_entity) { FactoryGirl.build(:related_entity, author: bob.diaspora_id) }
    let(:data) {
      FactoryGirl.build(
        :participation_entity,
        author:      alice.diaspora_id,
        parent_guid: parent.guid,
        parent_type: parent.entity_type,
        parent:      parent_entity
      ).send(:enriched_properties).merge(parent: parent_entity)
    }

    let(:xml) { <<-XML }
<participation>
  <guid>#{data[:guid]}</guid>
  <target_type>#{parent.entity_type}</target_type>
  <parent_guid>#{parent.guid}</parent_guid>
  <diaspora_handle>#{data[:author]}</diaspora_handle>
  <author_signature>#{data[:author_signature]}</author_signature>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
</participation>
XML

    let(:string) { "Participation:#{data[:guid]}:Post:#{parent.guid}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity", [:parent]

    it_behaves_like "a relayable Entity"

    describe "#sender_valid?" do
      let(:entity) { Entities::Participation.new(data) }

      it "allows the author" do
        expect(entity.sender_valid?(alice.diaspora_id)).to be_truthy
      end

      it "does not allow the parent author" do
        expect(entity.sender_valid?(bob.diaspora_id)).to be_falsey
      end
    end

    context "parse xml" do
      it "does not verify the signature" do
        data.merge!(author_signature: "aa", parent_author_signature: "bb")
        xml = Entities::Participation.new(data).to_xml

        expect {
          Entities::Participation.from_xml(xml)
        }.not_to raise_error
      end

      describe "#validate_parent" do
        let(:participation) {
          allow(DiasporaFederation.callbacks).to receive(:trigger).and_call_original
          Entities::Participation.new(data)
        }

        it "succeeds when the parent is local" do
          local_parent = FactoryGirl.build(:related_entity, local: true)
          expect_callback(:fetch_related_entity, parent.entity_type, parent.guid).and_return(local_parent)

          expect {
            Entities::Participation.from_xml(participation.to_xml)
          }.not_to raise_error
        end

        it "raises ParentNotLocal when the parent is not found" do
          expect_callback(:fetch_related_entity, parent.entity_type, parent.guid).and_return(nil)

          expect {
            Entities::Participation.from_xml(participation.to_xml)
          }.to raise_error Entities::Participation::ParentNotLocal, "obj=#{participation}"
        end

        it "raises ParentNotLocal when the parent is not local" do
          remote_parent = FactoryGirl.build(:related_entity, local: false)
          expect_callback(:fetch_related_entity, parent.entity_type, parent.guid).and_return(remote_parent)

          expect {
            Entities::Participation.from_xml(participation.to_xml)
          }.to raise_error Entities::Participation::ParentNotLocal, "obj=#{participation}"
        end
      end
    end
  end
end
