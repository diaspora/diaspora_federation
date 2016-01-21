module DiasporaFederation
  describe Entities::Comment do
    let(:data) { Test.attributes_with_signatures(:comment_entity) }

    let(:xml) {
      <<-XML
<comment>
  <guid>#{data[:guid]}</guid>
  <parent_guid>#{data[:parent_guid]}</parent_guid>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
  <author_signature>#{data[:author_signature]}</author_signature>
  <text>#{data[:text]}</text>
  <diaspora_handle>#{data[:diaspora_id]}</diaspora_handle>
</comment>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a relayable Entity"

    describe "#target_type" do
      it "returns \"Post\" as target type" do
        expect(described_class.new(data).target_type).to eq("Post")
      end
    end
  end
end
