module DiasporaFederation
  describe ReceiveController, type: :controller do
    routes { DiasporaFederation::Engine.routes }

    describe "POST #public" do
      it "succeeds" do
        post :public, xml: "<diaspora/>"
        expect(response).to be_success
      end

      it "returns a 422 if no xml is passed" do
        post :public
        expect(response.code).to eq("422")
      end
    end

    describe "POST #private" do
      it "succeeds" do
        post :private, guid: "any-guid", xml: "<diaspora/>"
        expect(response).to be_success
      end

      it "returns a 422 if no xml is passed" do
        post :private, guid: "any-guid"
        expect(response.code).to eq("422")
      end
    end
  end
end
