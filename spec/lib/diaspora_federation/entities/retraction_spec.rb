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
    let(:string) { "Retraction:#{data[:target_type]}:#{data[:target_guid]}" }

    it_behaves_like "an Entity subclass", [:target]

    it_behaves_like "an XML Entity"

    it_behaves_like "a retraction"

    describe "#sender_valid?" do
      context "unrelayable target" do
        it "allows target author" do
          entity = Entities::Retraction.new(data)

          expect(entity.sender_valid?(bob.diaspora_id)).to be_truthy
        end

        it "does not allow any random author" do
          entity = Entities::Retraction.new(data)
          invalid_author = FactoryGirl.generate(:diaspora_id)

          expect(entity.sender_valid?(invalid_author)).to be_falsey
        end
      end

      %w(Comment Like PollParticipation).each do |target_type|
        context "#{target_type} target" do
          let(:relayable_target) {
            FactoryGirl.build(
              :related_entity,
              author: bob.diaspora_id,
              parent: FactoryGirl.build(:related_entity, author: alice.diaspora_id)
            )
          }
          let(:relayable_data) { data.merge(target_type: target_type, target: relayable_target) }

          it "allows target author" do
            entity = Entities::Retraction.new(relayable_data)

            expect(entity.sender_valid?(bob.diaspora_id)).to be_truthy
          end

          it "allows target parent author" do
            entity = Entities::Retraction.new(relayable_data)

            expect(entity.sender_valid?(alice.diaspora_id)).to be_truthy
          end

          it "does not allow any random author" do
            entity = Entities::Retraction.new(relayable_data)
            invalid_author = FactoryGirl.generate(:diaspora_id)

            expect(entity.sender_valid?(invalid_author)).to be_falsey
          end
        end
      end
    end
  end
end
