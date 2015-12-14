module DiasporaFederation
  describe Entities::Participation do
    let(:data) { Test.relayable_attributes_with_signatures(:participation_entity) }

    let(:xml) {
      <<-XML
<participation>
  <guid>#{data[:guid]}</guid>
  <target_type>#{data[:target_type]}</target_type>
  <parent_guid>#{data[:parent_guid]}</parent_guid>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
  <author_signature>#{data[:author_signature]}</author_signature>
  <diaspora_handle>#{data[:diaspora_id]}</diaspora_handle>
</participation>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a relayable Entity"

    describe ".get_target_entity_type" do
      it "returns data[:target_type] as target type" do
        expect(described_class.get_target_entity_type(data)).to eq(data[:target_type])
      end
    end
  end
end
