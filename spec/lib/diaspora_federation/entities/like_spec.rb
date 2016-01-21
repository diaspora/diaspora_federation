module DiasporaFederation
  describe Entities::Like do
    let(:data) { Test.relayable_attributes_with_signatures(:like_entity) }

    let(:xml) {
      <<-XML
<like>
  <positive>#{data[:positive]}</positive>
  <guid>#{data[:guid]}</guid>
  <target_type>#{data[:target_type]}</target_type>
  <parent_guid>#{data[:parent_guid]}</parent_guid>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
  <author_signature>#{data[:author_signature]}</author_signature>
  <diaspora_handle>#{data[:diaspora_id]}</diaspora_handle>
</like>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a relayable Entity"

    describe "#target_type" do
      it "returns data[:target_type] as target type" do
        expect(described_class.new(data).target_type).to eq(data[:target_type])
      end
    end
  end
end
