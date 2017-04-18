# only some basic controller tests for rails 4
module DiasporaFederation
  describe WebfingerController, type: :controller, rails: 4 do
    routes { DiasporaFederation::Engine.routes }

    it "contains the webfinger result" do
      webfinger_xrd = DiasporaFederation::Discovery::WebFinger.new(
        acct_uri:      "acct:#{alice.diaspora_id}",
        alias_url:     alice.alias_url,
        hcard_url:     alice.hcard_url,
        seed_url:      alice.url,
        profile_url:   alice.profile_url,
        atom_url:      alice.atom_url,
        salmon_url:    alice.salmon_url,
        subscribe_url: alice.subscribe_url,
        guid:          alice.guid,
        public_key:    alice.serialized_public_key
      ).to_xml

      get :legacy_webfinger, q: alice.diaspora_id
      expect(response).to be_success
      expect(response.body).to eq(webfinger_xrd)
    end

    it "404s when the person does not exist" do
      get :legacy_webfinger, q: "me@mydiaspora.pod.com"
      expect(response).to be_not_found
    end
  end

  describe HCardController, type: :controller, rails: 4 do
    routes { DiasporaFederation::Engine.routes }

    it "contains the hcard result" do
      hcard_html = DiasporaFederation::Discovery::HCard.new(
        guid:             alice.guid,
        nickname:         alice.nickname,
        full_name:        alice.full_name,
        url:              alice.url,
        photo_large_url:  alice.photo_default_url,
        photo_medium_url: alice.photo_default_url,
        photo_small_url:  alice.photo_default_url,
        public_key:       alice.serialized_public_key,
        searchable:       alice.searchable,
        first_name:       alice.first_name,
        last_name:        alice.last_name
      ).to_html

      get :hcard, guid: alice.guid
      expect(response).to be_success
      expect(response.body).to eq(hcard_html)
    end

    it "404s when the person does not exist" do
      get :hcard, guid: "unknown_guid"
      expect(response).to be_not_found
    end
  end

  describe ReceiveController, type: :controller, rails: 4 do
    routes { DiasporaFederation::Engine.routes }

    describe "POST #public" do
      it "returns a 202 if queued correctly" do
        expect_callback(:queue_public_receive, "<diaspora/>", true)

        post :public, xml: "<diaspora/>"
        expect(response.code).to eq("202")
      end
    end

    describe "POST #private" do
      it "returns a 202 if the callback returned true" do
        expect_callback(:queue_private_receive, "any-guid", "<diaspora/>", true).and_return(true)

        post :private, guid: "any-guid", xml: "<diaspora/>"
        expect(response.code).to eq("202")
      end
    end
  end
end
