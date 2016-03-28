module DiasporaFederation
  describe Entities::Retraction do
    let(:target) { FactoryGirl.create(:post, author: bob) }
    let(:target_entity) { FactoryGirl.build(:related_entity, author: bob.diaspora_id) }
    let(:data) {
      FactoryGirl.attributes_for(
        :retraction_entity,
        target_guid: target.guid,
        target_type: target.entity_type,
        target:      target_entity
      )
    }

    let(:xml) {
      <<-XML
<retraction>
  <diaspora_handle>#{data[:author]}</diaspora_handle>
  <post_guid>#{data[:target_guid]}</post_guid>
  <type>#{data[:target_type]}</type>
</retraction>
XML
    }

    it_behaves_like "an Entity subclass", [:target]

    it_behaves_like "an XML Entity"
  end
end
