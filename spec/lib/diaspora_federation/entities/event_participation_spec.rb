module DiasporaFederation
  describe Entities::EventParticipation do
    let(:parent) { FactoryGirl.create(:event, author: bob) }
    let(:parent_entity) { FactoryGirl.build(:related_entity, author: bob.diaspora_id) }
    let(:data) {
      FactoryGirl.attributes_for(
        :event_participation_entity,
        author:      alice.diaspora_id,
        parent_guid: parent.guid,
        parent:      parent_entity
      ).tap {|hash| add_signatures(hash) }
    }

    let(:xml) { <<-XML }
<event_participation>
  <author>#{data[:author]}</author>
  <guid>#{data[:guid]}</guid>
  <parent_guid>#{parent.guid}</parent_guid>
  <status>#{data[:status]}</status>
  <author_signature>#{data[:author_signature]}</author_signature>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
</event_participation>
XML

    let(:string) { "EventParticipation:#{data[:guid]}:#{parent.guid}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a relayable Entity"
  end
end
