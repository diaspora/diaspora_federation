module DiasporaFederation
  describe Federation::Fetcher do
    let(:post) { FactoryGirl.build(:status_message_entity, public: true) }
    let(:post_magic_env) { Salmon::MagicEnvelope.new(post, post.author).envelop(alice.private_key).to_xml }

    describe ".fetch_public" do
      it "fetches a public post with symbol as type param" do
        stub_request(:get, "https://example.org/fetch/post/#{post.guid}")
          .to_return(status: 200, body: post_magic_env)

        expect_callback(:fetch_person_url_to, post.author, "/fetch/post/#{post.guid}")
          .and_return("https://example.org/fetch/post/#{post.guid}")
        expect_callback(:fetch_public_key, post.author).and_return(alice.public_key)

        receiver = double
        expect(Federation::Receiver::Public).to receive(:new).with(
          kind_of(Salmon::MagicEnvelope)
        ) do |magic_env|
          expect(magic_env.payload.guid).to eq(post.guid)
          expect(magic_env.payload.author).to eq(post.author)
          expect(magic_env.payload.text).to eq(post.text)
          expect(magic_env.payload.public).to eq("true")
          receiver
        end
        expect(receiver).to receive(:receive)

        Federation::Fetcher.fetch_public(post.author, :post, post.guid)
      end

      it "fetches a public post with class name as type param" do
        stub_request(:get, "https://example.org/fetch/post/#{post.guid}")
          .to_return(status: 200, body: post_magic_env)

        expect_callback(:fetch_person_url_to, post.author, "/fetch/post/#{post.guid}")
          .and_return("https://example.org/fetch/post/#{post.guid}")
        expect_callback(:fetch_public_key, post.author).and_return(alice.public_key)

        receiver = double
        expect(Federation::Receiver::Public).to receive(:new).with(
          kind_of(Salmon::MagicEnvelope)
        ) do |magic_env|
          expect(magic_env.payload.guid).to eq(post.guid)
          expect(magic_env.payload.author).to eq(post.author)
          expect(magic_env.payload.text).to eq(post.text)
          expect(magic_env.payload.public).to eq("true")
          receiver
        end
        expect(receiver).to receive(:receive)

        Federation::Fetcher.fetch_public(post.author, "Post", post.guid)
      end

      it "follows redirects" do
        stub_request(:get, "https://example.org/fetch/post/#{post.guid}")
          .to_return(status: 302, headers: {"Location" => "https://example.com/fetch/post/#{post.guid}"})
        stub_request(:get, "https://example.com/fetch/post/#{post.guid}")
          .to_return(status: 200, body: post_magic_env)

        expect_callback(:fetch_person_url_to, post.author, "/fetch/post/#{post.guid}")
          .and_return("https://example.org/fetch/post/#{post.guid}")
        expect_callback(:fetch_public_key, post.author).and_return(alice.public_key)

        receiver = double
        expect(Federation::Receiver::Public).to receive(:new).with(
          kind_of(Salmon::MagicEnvelope)
        ).and_return(receiver)
        expect(receiver).to receive(:receive)

        Federation::Fetcher.fetch_public(post.author, :post, post.guid)
      end

      it "raises NotFetchable if post not found (private)" do
        stub_request(:get, "https://example.org/fetch/post/#{post.guid}")
          .to_return(status: 404)

        expect_callback(:fetch_person_url_to, post.author, "/fetch/post/#{post.guid}")
          .and_return("https://example.org/fetch/post/#{post.guid}")

        expect {
          Federation::Fetcher.fetch_public(post.author, :post, post.guid)
        }.to raise_error Federation::Fetcher::NotFetchable
      end

      it "raises NotFetchable if connection refused" do
        expect(HttpClient).to receive(:get).with(
          "https://example.org/fetch/post/#{post.guid}"
        ).and_raise(Faraday::ConnectionFailed, "Couldn't connect to server")

        expect_callback(:fetch_person_url_to, post.author, "/fetch/post/#{post.guid}")
          .and_return("https://example.org/fetch/post/#{post.guid}")

        expect {
          Federation::Fetcher.fetch_public(post.author, :post, post.guid)
        }.to raise_error Federation::Fetcher::NotFetchable
      end
    end
  end
end
