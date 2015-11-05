module DiasporaFederation
  describe Entities::SignedRetraction do
    let(:data) { FactoryGirl.attributes_for(:signed_retraction_entity) }

    let(:xml) {
      <<-XML
<signed_retraction>
  <target_guid>#{data[:target_guid]}</target_guid>
  <target_type>#{data[:target_type]}</target_type>
  <sender_handle>#{data[:sender_id]}</sender_handle>
  <target_author_signature>#{data[:target_author_signature]}</target_author_signature>
</signed_retraction>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
