module DiasporaFederation
  describe Discovery::Discovery do
    let(:host_meta_xrd) { FixtureGeneration.load_fixture("host-meta") }
    let(:webfinger_xrd) { FixtureGeneration.load_fixture("legacy-webfinger") }
    let(:hcard_html) { FixtureGeneration.load_fixture("hcard") }
    let(:account) { alice.diaspora_id }
    let(:default_image) { "http://localhost:3000/assets/user/default.png" }

    describe "#intialize" do
      it "sets diaspora id" do
        discovery = Discovery::Discovery.new("some_user@example.com")
        expect(discovery.diaspora_id).to eq("some_user@example.com")
      end

      it "downcases account and strips whitespace, and sub 'acct:'" do
        discovery = Discovery::Discovery.new("acct:BIGBOY@Example.Com ")
        expect(discovery.diaspora_id).to eq("bigboy@example.com")
      end
    end

    describe ".fetch" do
      it "fetches the userdata and returns a person object" do
        stub_request(:get, "https://localhost:3000/.well-known/host-meta")
          .to_return(status: 200, body: host_meta_xrd)
        stub_request(:get, "http://localhost:3000/webfinger?q=acct:#{account}")
          .to_return(status: 200, body: webfinger_xrd)
        stub_request(:get, "http://localhost:3000/hcard/users/#{alice.guid}")
          .to_return(status: 200, body: hcard_html)

        person = Discovery::Discovery.new(account).fetch

        expect(person.guid).to eq(alice.guid)
        expect(person.diaspora_id).to eq(account)
        expect(person.url).to eq(alice.url)
        expect(person.exported_key).to eq(alice.serialized_public_key)

        profile = person.profile

        expect(profile.diaspora_id).to eq(alice.diaspora_id)
        expect(profile.first_name).to eq("Dummy")
        expect(profile.last_name).to eq("User")

        expect(profile.image_url).to eq(default_image)
        expect(profile.image_url_medium).to eq(default_image)
        expect(profile.image_url_small).to eq(default_image)
      end

      it "falls back to http if https fails with 404" do
        stub_request(:get, "https://localhost:3000/.well-known/host-meta")
          .to_return(status: 404)
        stub_request(:get, "http://localhost:3000/.well-known/host-meta")
          .to_return(status: 200, body: host_meta_xrd)
        stub_request(:get, "http://localhost:3000/webfinger?q=acct:#{account}")
          .to_return(status: 200, body: webfinger_xrd)
        stub_request(:get, "http://localhost:3000/hcard/users/#{alice.guid}")
          .to_return(status: 200, body: hcard_html)

        person = Discovery::Discovery.new(account).fetch

        expect(person.guid).to eq(alice.guid)
        expect(person.diaspora_id).to eq(account)
      end

      it "falls back to http if https fails with ssl error" do
        stub_request(:get, "https://localhost:3000/.well-known/host-meta")
          .to_raise(OpenSSL::SSL::SSLError)
        stub_request(:get, "http://localhost:3000/.well-known/host-meta")
          .to_return(status: 200, body: host_meta_xrd)
        stub_request(:get, "http://localhost:3000/webfinger?q=acct:#{account}")
          .to_return(status: 200, body: webfinger_xrd)
        stub_request(:get, "http://localhost:3000/hcard/users/#{alice.guid}")
          .to_return(status: 200, body: hcard_html)

        person = Discovery::Discovery.new(account).fetch

        expect(person.guid).to eq(alice.guid)
        expect(person.diaspora_id).to eq(account)
      end

      it "fails if the diaspora id does not match" do
        modified_webfinger = webfinger_xrd.gsub(account, "anonther_user@example.com")

        stub_request(:get, "https://localhost:3000/.well-known/host-meta")
          .to_return(status: 200, body: host_meta_xrd)
        stub_request(:get, "http://localhost:3000/webfinger?q=acct:#{account}")
          .to_return(status: 200, body: modified_webfinger)

        expect { Discovery::Discovery.new(account).fetch }.to raise_error Discovery::DiscoveryError
      end

      it "fails if the diaspora id was not found" do
        stub_request(:get, "https://localhost:3000/.well-known/host-meta")
          .to_return(status: 200, body: host_meta_xrd)
        stub_request(:get, "http://localhost:3000/webfinger?q=acct:#{account}")
          .to_return(status: 404)

        expect { Discovery::Discovery.new(account).fetch }.to raise_error Discovery::DiscoveryError
      end

      it "reads old hcard without guid and public key" do
        historic_hcard_html = <<-HTML
<div id="content">
<h1>#{account}</h1>
<div id="content_inner">
<div class="entity_profile vcard author" id="i">
<h2>User profile</h2>
<dl class="entity_nickname">
<dt>Nickname</dt>
<dd>
<a class="nickname url uid" href="#{alice.url}" rel="me"></a>
</dd>
</dl>
<dl class="entity_given_name">
<dt>First name</dt>
<dd>
<span class="given_name"></span>
</dd>
</dl>
<dl class="entity_family_name">
<dt>Family name</dt>
<dd>
<span class="family_name"></span>
</dd>
</dl>
<dl class="entity_fn">
<dt>Full name</dt>
<dd>
<span class="fn"></span>
</dd>
</dl>
<dl class="entity_url">
<dt>URL</dt>
<dd>
<a class="url" href="#{alice.url}" id="pod_location" rel="me">#{alice.url}</a>
</dd>
</dl>
<dl class="entity_photo">
<dt>Photo</dt>
<dd>
<img class="photo avatar" height="300px" src="#{default_image}" width="300px">
</dd>
</dl>
<dl class="entity_photo_medium">
<dt>Photo</dt>
<dd>
<img class="photo avatar" height="100px" src="#{default_image}" width="100px">
</dd>
</dl>
<dl class="entity_photo_small">
<dt>Photo</dt>
<dd>
<img class="photo avatar" height="50px" src="#{default_image}" width="50px">
</dd>
</dl>
<dl class="entity_searchable">
<dt>Searchable</dt>
<dd>
<span class="searchable">true</span>
</dd>
</dl>
</div>
</div>
</div>
        HTML

        stub_request(:get, "https://localhost:3000/.well-known/host-meta")
          .to_return(status: 200, body: host_meta_xrd)
        stub_request(:get, "http://localhost:3000/webfinger?q=acct:#{account}")
          .to_return(status: 200, body: webfinger_xrd)
        stub_request(:get, "http://localhost:3000/hcard/users/#{alice.guid}")
          .to_return(status: 200, body: historic_hcard_html)

        person = Discovery::Discovery.new(account).fetch

        expect(person.guid).to eq(alice.guid)
        expect(person.diaspora_id).to eq(account)
        expect(person.url).to eq(alice.url)
        expect(person.exported_key).to eq(alice.serialized_public_key)

        profile = person.profile

        expect(profile.diaspora_id).to eq(alice.diaspora_id)
        expect(profile.first_name).to be_nil
        expect(profile.last_name).to be_nil

        expect(profile.image_url).to eq(default_image)
        expect(profile.image_url_medium).to eq(default_image)
        expect(profile.image_url_small).to eq(default_image)
      end
    end
  end
end
