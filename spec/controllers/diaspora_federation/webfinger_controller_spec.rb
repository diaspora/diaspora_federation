module DiasporaFederation
  describe WebfingerController, type: :controller do
    routes { DiasporaFederation::Engine.routes }

    describe "#host_meta" do
      before do
        DiasporaFederation.server_uri = URI("http://localhost:3000/")
      end

      it "succeeds" do
        get :host_meta
        expect(response).to be_success
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
    end

    describe "#legacy_webfinger" do
      it "succeeds when the person exists" do
        post :legacy_webfinger, "q" => "alice@localhost:3000"
        expect(response).to be_success
      end

      it "succeeds with 'acct:' in the query when the person exists" do
        post :legacy_webfinger, "q" => "acct:alice@localhost:3000"
        expect(response).to be_success
      end

      it "404s when the person does not exist" do
        post :legacy_webfinger, "q" => "me@mydiaspora.pod.com"
        expect(response).to be_not_found
      end
    end
  end
end
