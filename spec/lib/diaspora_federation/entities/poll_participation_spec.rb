module DiasporaFederation
  describe Entities::PollParticipation do
    let(:parent) { FactoryGirl.create(:poll, author: bob) }
    let(:parent_entity) { FactoryGirl.build(:related_entity, author: bob.diaspora_id) }
    let(:data) {
      FactoryGirl.attributes_for(
        :poll_participation_entity,
        author:      alice.diaspora_id,
        parent_guid: parent.guid,
        parent:      parent_entity
      ).tap {|hash| add_signatures(hash) }
    }

    let(:xml) { <<-XML }
<poll_participation>
  <guid>#{data[:guid]}</guid>
  <parent_guid>#{parent.guid}</parent_guid>
  <diaspora_handle>#{data[:author]}</diaspora_handle>
  <poll_answer_guid>#{data[:poll_answer_guid]}</poll_answer_guid>
  <author_signature>#{data[:author_signature]}</author_signature>
  <parent_author_signature>#{data[:parent_author_signature]}</parent_author_signature>
</poll_participation>
XML

    let(:string) { "PollParticipation:#{data[:guid]}:#{parent.guid}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity"

    it_behaves_like "a relayable Entity"
  end
end
