module DiasporaFederation
  describe WebfingerController, type: :controller do
    routes { DiasporaFederation::Engine.routes }

    describe "GET #host_meta" do
      before do
        DiasporaFederation.server_uri = URI("http://localhost:3000/")
        WebfingerController.instance_variable_set(:@host_meta_xml, nil) # clear cache
      end

      it "succeeds", fixture: true do
        get :host_meta
        expect(response).to be_success
        save_fixture(response.body, "host-meta")
      end

      it "contains the webfinger-template" do
        get :host_meta
        expect(response.body).to include "template=\"http://localhost:3000/webfinger?q={uri}\""
      end

      it "returns a application/xrd+xml" do
        get :host_meta
        expect(response.header["Content-Type"]).to include "application/xrd+xml"
      end

      it "calls WebFinger::HostMeta.from_base_url with the base url" do
        expect(WebFinger::HostMeta).to receive(:from_base_url).with("http://localhost:3000/").and_call_original
        get :host_meta
      end

      it "caches the xml" do
        expect(WebFinger::HostMeta).to receive(:from_base_url).exactly(1).times.and_call_original
        get :host_meta
        get :host_meta
      end
    end

    describe "GET #legacy_webfinger" do
      it "succeeds when the person exists", fixture: true do
        get :legacy_webfinger, "q" => "alice@localhost:3000"
        expect(response).to be_success
        save_fixture(response.body, "legacy-webfinger")
      end

      it "succeeds with 'acct:' in the query when the person exists" do
        get :legacy_webfinger, "q" => "acct:alice@localhost:3000"
        expect(response).to be_success
      end

      it "contains the diaspora handle" do
        get :legacy_webfinger, "q" => "acct:alice@localhost:3000"
        expect(response.body).to include "<Subject>acct:alice@localhost:3000</Subject>"
      end

      it "404s when the person does not exist" do
        get :legacy_webfinger, "q" => "me@mydiaspora.pod.com"
        expect(response).to be_not_found
      end

      it "calls WebFinger::WebFinger.from_person" do
        expect(WebFinger::WebFinger).to receive(:from_person).with(alice.webfinger_hash).and_call_original
        get :legacy_webfinger, "q" => "acct:alice@localhost:3000"
      end
    end
  end
end
