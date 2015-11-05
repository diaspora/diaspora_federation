module DiasporaFederation
  describe Entities::Like do
    let(:data) { FactoryGirl.attributes_for(:like_entity) }

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
  end
end
