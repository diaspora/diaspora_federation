module DiasporaFederation
  describe ReceiveController, type: :controller do
    routes { DiasporaFederation::Engine.routes }

    describe "POST #public" do
      it "raises on an empty object" do
        expect { post :public, xml: "<diaspora/>" }.to raise_error(Salmon::MissingAuthor)
      end

      it "returns a 422 if no xml is passed" do
        post :public
        expect(response.code).to eq("422")
      end

      it "returns a 200 if receive! reports no errors" do
        expect_any_instance_of(Receiver::Public).to receive(:receive!)

        post :public, xml: "<diaspora/>"
        expect(response.code).to eq("200")
      end
    end

    describe "POST #private" do
      it "return 404 for because of an unknown guid" do
        post :private, guid: "any-guid", xml: "<diaspora/>"
        expect(response.code).to eq("404")
      end

      it "returns a 422 if no xml is passed" do
        post :private, guid: "any-guid"
        expect(response.code).to eq("422")
      end

      it "returns a 200 if receive! reports no errors" do
        expect(DiasporaFederation.callbacks).to receive(:trigger)
                                                  .with(:fetch_private_key_by_user_guid, "any-guid")
                                                  .once
                                                  .and_return(true)
        expect_any_instance_of(Receiver::Private).to receive(:receive!)

        post :private, guid: "any-guid", xml: "<diaspora/>"
        expect(response.code).to eq("200")
      end
    end
  end
end
