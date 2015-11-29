module DiasporaFederation
  describe Entities::Retraction do
    let(:data) { FactoryGirl.attributes_for(:retraction_entity) }

    let(:xml) {
      <<-XML
<retraction>
  <post_guid>#{data[:target_guid]}</post_guid>
  <diaspora_handle>#{data[:diaspora_id]}</diaspora_handle>
  <type>#{data[:target_type]}</type>
</retraction>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
