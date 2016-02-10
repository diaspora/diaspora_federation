module DiasporaFederation
  describe Entities::Retraction do
    let(:data) { FactoryGirl.attributes_for(:retraction_entity) }

    let(:xml) {
      <<-XML
<retraction>
  <diaspora_handle>#{data[:author]}</diaspora_handle>
  <post_guid>#{data[:target_guid]}</post_guid>
  <type>#{data[:target_type]}</type>
</retraction>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
