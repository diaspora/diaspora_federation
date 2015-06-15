module DiasporaFederation
  describe WebfingerController, type: :controller do
    routes { DiasporaFederation::Engine.routes }

    describe "#host_meta" do
      it "succeeds" do
        get :host_meta
        expect(response).to be_success
      end

      it "contains the webfinger-template" do
        DiasporaFederation.server_uri = "http://localhost:3000/"
        get :host_meta
        expect(response.body).to include "template=\"http://localhost:3000/webfinger?q={uri}\""
      end

      it "renders the host_meta template" do
        get :host_meta
        expect(response).to render_template("host_meta")
        expect(response.header["Content-Type"]).to include "application/xrd+xml"
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
