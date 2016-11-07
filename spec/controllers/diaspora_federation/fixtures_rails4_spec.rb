module DiasporaFederation
  describe WebfingerController, type: :controller do
    routes { DiasporaFederation::Engine.routes }

    it "generates webfinger fixture", fixture4: true, rails4: true do
      get :legacy_webfinger, q: "alice@localhost:3000"
      expect(response).to be_success
      save_fixture(response.body, "legacy-webfinger")
    end
  end

  describe HCardController, type: :controller do
    routes { DiasporaFederation::Engine.routes }

    it "generates hcard fixture", fixture4: true, rails4: true do
      get :hcard, guid: alice.guid
      expect(response).to be_success
      save_fixture(response.body, "hcard")
    end
  end
end
