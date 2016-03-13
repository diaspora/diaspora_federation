module DiasporaFederation
  describe Federation::Fetcher do
    let(:post) { FactoryGirl.build(:status_message_entity, public: true) }
    let(:post_magic_env) { Salmon::MagicEnvelope.new(post).envelop(alice.private_key, post.author).to_xml }

    describe ".fetch_public" do
      it "fetches a public post" do
        stub_request(:get, "https://example.org/fetch/post/#{post.guid}")
          .to_return(status: 200, body: post_magic_env)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_person_url_to, post.author, "/fetch/post/#{post.guid}"
        ).and_return("https://example.org/fetch/post/#{post.guid}")
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_public_key_by_diaspora_id, post.author
        ).and_return(alice.public_key)
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :save_entity_after_receive, kind_of(Entities::StatusMessage)
        ) do |_, entity|
          expect(entity.guid).to eq(post.guid)
          expect(entity.author).to eq(post.author)
          expect(entity.raw_message).to eq(post.raw_message)
          expect(entity.public).to eq("true")
        end

        Federation::Fetcher.fetch_public(post.author, :post, post.guid)
      end

      it "follows redirects" do
        stub_request(:get, "https://example.org/fetch/post/#{post.guid}")
          .to_return(status: 302, headers: {"Location" => "https://example.com/fetch/post/#{post.guid}"})
        stub_request(:get, "https://example.com/fetch/post/#{post.guid}")
          .to_return(status: 200, body: post_magic_env)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_person_url_to, post.author, "/fetch/post/#{post.guid}"
        ).and_return("https://example.org/fetch/post/#{post.guid}")
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_public_key_by_diaspora_id, post.author
        ).and_return(alice.public_key)
        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :save_entity_after_receive, kind_of(Entities::StatusMessage)
        )

        Federation::Fetcher.fetch_public(post.author, :post, post.guid)
      end

      it "raises NotFetchable if post not found (private)" do
        stub_request(:get, "https://example.org/fetch/post/#{post.guid}")
          .to_return(status: 404)

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_person_url_to, post.author, "/fetch/post/#{post.guid}"
        ).and_return("https://example.org/fetch/post/#{post.guid}")

        expect {
          Federation::Fetcher.fetch_public(post.author, :post, post.guid)
        }.to raise_error Federation::Fetcher::NotFetchable
      end

      it "raises NotFetchable if connection refused" do
        expect(HttpClient).to receive(:get).with(
          "https://example.org/fetch/post/#{post.guid}"
        ).and_raise(Faraday::ConnectionFailed, "Couldn't connect to server")

        expect(DiasporaFederation.callbacks).to receive(:trigger).with(
          :fetch_person_url_to, post.author, "/fetch/post/#{post.guid}"
        ).and_return("https://example.org/fetch/post/#{post.guid}")

        expect {
          Federation::Fetcher.fetch_public(post.author, :post, post.guid)
        }.to raise_error Federation::Fetcher::NotFetchable
      end
    end
  end
end
