module DiasporaFederation
  describe ReceiveController, type: :controller do
    routes { DiasporaFederation::Engine.routes }

    describe "POST #public" do
      it "returns a 422 if no xml is passed" do
        post :public
        expect(response.code).to eq("422")
      end

      it "returns a 200 if queued correctly" do
        expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                  .with(:queue_public_receive, "<diaspora/>")

        post :public, xml: "<diaspora/>"
        expect(response.code).to eq("200")
      end
    end

    describe "POST #private" do
      it "return a 404 if not queued successfully (unknown user guid)" do
        expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                  .with(:queue_private_receive, "any-guid", "<diaspora/>")
                                                  .and_return(false)

        post :private, guid: "any-guid", xml: "<diaspora/>"
        expect(response.code).to eq("404")
      end

      it "returns a 422 if no xml is passed" do
        post :private, guid: "any-guid"
        expect(response.code).to eq("422")
      end

      it "returns a 200 if receive! reports no errors" do
        expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                  .with(:queue_private_receive, "any-guid", "<diaspora/>")
                                                  .and_return(true)

        post :private, guid: "any-guid", xml: "<diaspora/>"
        expect(response.code).to eq("200")
      end
    end
  end
end
