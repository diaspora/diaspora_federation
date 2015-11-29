module DiasporaFederation
  describe Entities::RelayableRetraction do
    let(:data) { FactoryGirl.attributes_for(:relayable_retraction_entity) }

    let(:xml) {
      <<-XML
<relayable_retraction>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
  <target_guid>#{data[:target_guid]}</target_guid>
  <target_type>#{data[:target_type]}</target_type>
  <sender_handle>#{data[:diaspora_id]}</sender_handle>
  <target_author_signature>#{data[:target_author_signature]}</target_author_signature>
</relayable_retraction>
XML
    }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"
  end
end
