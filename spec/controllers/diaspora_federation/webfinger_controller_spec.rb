# frozen_string_literal: true

module DiasporaFederation
  describe WebfingerController, type: :controller do
    routes { DiasporaFederation::Engine.routes }

    describe "GET #host_meta" do
      before do
        DiasporaFederation.server_uri = URI("http://localhost:3000/")
        WebfingerController.instance_variable_set(:@host_meta_xml, nil) # clear cache
      end

      it "succeeds" do
        get :host_meta
        expect(response).to be_successful
      end

      it "contains the webfinger-template" do
        get :host_meta
        expect(response.body).to include "template=\"http://localhost:3000/.well-known/webfinger.xml?resource={uri}\""
      end

      it "returns a application/xrd+xml" do
        get :host_meta
        expect(response.header["Content-Type"]).to include "application/xrd+xml"
      end

      it "calls Discovery::HostMeta.from_base_url with the base url" do
        expect(Discovery::HostMeta).to receive(:from_base_url).with("http://localhost:3000/").and_call_original
        get :host_meta
      end

      it "caches the xml" do
        expect(Discovery::HostMeta).to receive(:from_base_url).exactly(1).times.and_call_original
        get :host_meta
        get :host_meta
      end
    end

    describe "GET #webfinger" do
      it "uses the JRD format as default" do
        get :webfinger, params: {resource: alice.diaspora_id}
        expect(response).to be_successful
        expect(response.header["Content-Type"]).to include "application/jrd+json"
      end

      context "json", exceptions: :catch do
        it "succeeds when the person exists" do
          get :webfinger, format: :json, params: {resource: alice.diaspora_id}
          expect(response).to be_successful
        end

        it "succeeds with 'acct:' in the query when the person exists" do
          get :webfinger, format: :json, params: {resource: "acct:#{alice.diaspora_id}"}
          expect(response).to be_successful
        end

        it "contains the diaspora* ID" do
          get :webfinger, format: :json, params: {resource: "acct:#{alice.diaspora_id}"}
          expect(response.body).to include "\"subject\": \"acct:alice@localhost:3000\""
        end

        it "returns a application/jrd+json" do
          get :webfinger, format: :json, params: {resource: "acct:#{alice.diaspora_id}"}
          expect(response.header["Content-Type"]).to include "application/jrd+json"
        end

        it "adds a Access-Control-Allow-Origin header" do
          get :webfinger, format: :json, params: {resource: "acct:#{alice.diaspora_id}"}
          expect(response.header["Access-Control-Allow-Origin"]).to eq("*")
        end

        it "404s when the person does not exist" do
          get :webfinger, format: :json, params: {resource: "me@mydiaspora.pod.com"}
          expect(response).to be_not_found
        end

        it "raises when the resource parameter is missing" do
          expect {
            get :webfinger, format: :json
          }.to raise_error ActionController::ParameterMissing, "param is missing or the value is empty: resource"
        end

        it "calls the fetch_person_for_webfinger callback" do
          expect_callback(:fetch_person_for_webfinger, "alice@localhost:3000").and_call_original

          get :webfinger, format: :json, params: {resource: "acct:alice@localhost:3000"}
        end
      end

      context "xml" do
        it "succeeds when the person exists" do
          get :webfinger, format: :json, params: {resource: alice.diaspora_id}
          expect(response).to be_successful
        end

        it "succeeds with 'acct:' in the query when the person exists" do
          get :webfinger, format: :xml, params: {resource: "acct:#{alice.diaspora_id}"}
          expect(response).to be_successful
        end

        it "contains the diaspora* ID" do
          get :webfinger, format: :xml, params: {resource: "acct:#{alice.diaspora_id}"}
          expect(response.body).to include "<Subject>acct:alice@localhost:3000</Subject>"
        end

        it "returns a application/xrd+xml" do
          get :webfinger, format: :xml, params: {resource: "acct:#{alice.diaspora_id}"}
          expect(response.header["Content-Type"]).to include "application/xrd+xml"
        end

        it "404s when the person does not exist" do
          get :webfinger, format: :xml, params: {resource: "me@mydiaspora.pod.com"}
          expect(response).to be_not_found
        end

        it "calls the fetch_person_for_webfinger callback" do
          expect_callback(:fetch_person_for_webfinger, "alice@localhost:3000").and_call_original

          get :webfinger, format: :xml, params: {resource: "acct:alice@localhost:3000"}
        end
      end
    end
  end
end
