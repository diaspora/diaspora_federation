module DiasporaFederation
  describe Federation::Receiver::Public do
    let(:post) { FactoryGirl.build(:status_message_entity) }
    let(:magic_env) { Salmon::MagicEnvelope.new(post, post.author) }

    describe "#receive" do
      it "receives a public post" do
        expect_callback(:receive_entity, post, nil)

        described_class.new(magic_env).receive
      end

      it "validates the sender" do
        sender = FactoryGirl.generate(:diaspora_id)
        bad_env = Salmon::MagicEnvelope.new(post, sender)

        expect {
          described_class.new(bad_env).receive
        }.to raise_error Federation::Receiver::InvalidSender
      end

      context "with relayable" do
        let(:comment) { FactoryGirl.build(:comment_entity) }

        it "receives a comment from the author" do
          magic_env = Salmon::MagicEnvelope.new(comment, comment.author)

          expect_callback(:receive_entity, comment, nil)

          described_class.new(magic_env).receive
        end

        it "receives a comment from the author parent" do
          magic_env = Salmon::MagicEnvelope.new(comment, comment.parent.author)

          expect_callback(:receive_entity, comment, nil)

          described_class.new(magic_env).receive
        end

        it "validates the sender" do
          sender = FactoryGirl.generate(:diaspora_id)
          bad_env = Salmon::MagicEnvelope.new(comment, sender)

          expect {
            described_class.new(bad_env).receive
          }.to raise_error Federation::Receiver::InvalidSender
        end
      end

      context "with retraction" do
        context "for a post" do
          let(:retraction) { FactoryGirl.build(:retraction_entity, target_type: "Post") }

          it "retracts a post from the author" do
            magic_env = Salmon::MagicEnvelope.new(retraction, retraction.target.author)

            expect_callback(:receive_entity, retraction, nil)

            described_class.new(magic_env).receive
          end

          it "validates the sender" do
            sender = FactoryGirl.generate(:diaspora_id)
            bad_env = Salmon::MagicEnvelope.new(retraction, sender)

            expect {
              described_class.new(bad_env).receive
            }.to raise_error Federation::Receiver::InvalidSender
          end
        end

        context "for a comment" do
          let(:retraction) {
            FactoryGirl.build(
              :retraction_entity,
              target_type: "Comment",
              target:      FactoryGirl.build(:related_entity, parent: FactoryGirl.build(:related_entity))
            )
          }

          it "retracts a comment from the author" do
            magic_env = Salmon::MagicEnvelope.new(retraction, retraction.target.author)

            expect_callback(:receive_entity, retraction, nil)

            described_class.new(magic_env).receive
          end

          it "retracts a comment from the parent author" do
            magic_env = Salmon::MagicEnvelope.new(retraction, retraction.target.parent.author)

            expect_callback(:receive_entity, retraction, nil)

            described_class.new(magic_env).receive
          end

          it "validates the sender" do
            sender = FactoryGirl.generate(:diaspora_id)
            bad_env = Salmon::MagicEnvelope.new(retraction, sender)

            expect {
              described_class.new(bad_env).receive
            }.to raise_error Federation::Receiver::InvalidSender
          end
        end
      end

      context "validates if it is public" do
        it "allows public entities" do
          public_post = FactoryGirl.build(:status_message_entity, public: true)
          magic_env = Salmon::MagicEnvelope.new(public_post, public_post.author)

          expect_callback(:receive_entity, public_post, nil)

          described_class.new(magic_env).receive
        end

        it "does not allow non-public entities" do
          private_post = FactoryGirl.build(:status_message_entity, public: false)
          magic_env = Salmon::MagicEnvelope.new(private_post, private_post.author)

          expect {
            described_class.new(magic_env).receive
          }.to raise_error Federation::Receiver::NotPublic
        end

        it "allows entities without public flag" do
          profile = FactoryGirl.build(:profile_entity)
          magic_env = Salmon::MagicEnvelope.new(profile, profile.author)

          expect_callback(:receive_entity, profile, nil)

          described_class.new(magic_env).receive
        end
      end
    end
  end
end
