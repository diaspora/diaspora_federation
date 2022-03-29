# frozen_string_literal: true

module DiasporaFederation
  describe Entities::Comment do
    let(:parent) { Fabricate(:post, author: bob) }
    let(:parent_entity) { Fabricate(:related_entity, author: bob.diaspora_id) }
    let(:parent_comment) { Fabricate(:comment) }
    let(:data) {
      Fabricate
        .attributes_for(
          :comment_entity,
          author:             alice.diaspora_id,
          parent_guid:        parent.guid,
          parent:             parent_entity,
          thread_parent_guid: parent_comment.guid
        ).tap {|hash| add_signatures(hash) }
    }

    let(:xml) { <<~XML }
      <comment>
        <author>#{data[:author]}</author>
        <guid>#{data[:guid]}</guid>
        <parent_guid>#{parent.guid}</parent_guid>
        <text>#{data[:text]}</text>
        <created_at>#{data[:created_at].utc.iso8601}</created_at>
        <edited_at>#{data[:edited_at].utc.iso8601}</edited_at>
        <thread_parent_guid>#{parent_comment.guid}</thread_parent_guid>
        <author_signature>#{data[:author_signature]}</author_signature>
      </comment>
    XML

    let(:json) { <<~JSON }
      {
        "entity_type": "comment",
        "entity_data": {
          "author": "#{data[:author]}",
          "guid": "#{data[:guid]}",
          "parent_guid": "#{parent.guid}",
          "author_signature": "#{data[:author_signature]}",
          "text": "#{data[:text]}",
          "created_at": "#{data[:created_at].iso8601}",
          "edited_at": "#{data[:edited_at].iso8601}",
          "thread_parent_guid": "#{parent_comment.guid}"
        },
        "property_order": [
          "author",
          "guid",
          "parent_guid",
          "text",
          "created_at",
          "edited_at",
          "thread_parent_guid"
        ]
      }
    JSON

    let(:string) { "Comment:#{data[:guid]}:#{parent.guid}" }

    it_behaves_like "an Entity subclass"

    it_behaves_like "an XML Entity", [:created_at]

    it_behaves_like "a JSON Entity"

    it_behaves_like "a relayable Entity"

    it_behaves_like "a relayable JSON entity"
  end
end
