module DiasporaFederation
  describe FetchController, type: :controller do
    routes { DiasporaFederation::Engine.routes }

    let(:guid) { "12345678901234567890" }
    let(:post) { FactoryGirl.build(:status_message_entity, guid: guid, author: alice.diaspora_id) }

    describe "GET #fetch" do
      it "returns the magic-envelope with the status message" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_public_entity, "StatusMessage", guid
        ).and_return(post)
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_private_key_by_diaspora_id, alice.diaspora_id
        ).and_return(alice.private_key)

        get :fetch, type: "status_message", guid: guid

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_public_key_by_diaspora_id, alice.diaspora_id
        ).and_return(alice.public_key)

        magic_env = Nokogiri::XML::Document.parse(response.body).root
        entity = Salmon::MagicEnvelope.unenvelop(magic_env)

        expect(entity).to be_a(Entities::StatusMessage)
        expect(entity.guid).to eq(guid)
        expect(entity.author).to eq(alice.diaspora_id)
        expect(entity.raw_message).to eq(post.raw_message)
      end

      it "works with type 'post'" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_public_entity, "Post", guid
        ).and_return(post)
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_private_key_by_diaspora_id, alice.diaspora_id
        ).and_return(alice.private_key)

        get :fetch, type: "post", guid: guid

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_public_key_by_diaspora_id, alice.diaspora_id
        ).and_return(alice.public_key)

        magic_env = Nokogiri::XML::Document.parse(response.body).root
        entity = Salmon::MagicEnvelope.unenvelop(magic_env)

        expect(entity).to be_a(Entities::StatusMessage)
        expect(entity.guid).to eq(guid)
        expect(entity.author).to eq(alice.diaspora_id)
        expect(entity.raw_message).to eq(post.raw_message)
      end

      it "redirects when the entity is from another pod" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_public_entity, "Post", guid
        ).and_return(post)
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_private_key_by_diaspora_id, alice.diaspora_id
        ).and_return(nil)
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_person_url_to, alice.diaspora_id, "/fetch/post/#{guid}"
        ).and_return("http://example.org/fetch/post/#{guid}")

        get :fetch, type: "post", guid: guid

        expect(response).to be_redirect
        expect(response).to redirect_to "http://example.org/fetch/post/#{guid}"
      end

      it "404s when the post does not exist" do
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_public_entity, "Post", guid
        ).and_return(nil)

        get :fetch, type: "post", guid: guid

        expect(response.status).to eq(404)
      end
    end
  end
end
