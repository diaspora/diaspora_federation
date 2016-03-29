module DiasporaFederation
  describe HCardController, type: :controller do
    routes { DiasporaFederation::Engine.routes }

    describe "GET #hcard" do
      it "succeeds when the person exists", fixture: true do
        get :hcard, "guid" => alice.guid
        expect(response).to be_success
        save_fixture(response.body, "hcard")
      end

      it "contains the guid" do
        get :hcard, "guid" => alice.guid
        expect(response.body).to include "<span class=\"uid\">#{alice.guid}</span>"
      end

      it "contains the username" do
        get :hcard, "guid" => alice.guid
        expect(response.body).to include "<span class=\"nickname\">alice</span>"
      end

      it "404s when the person does not exist" do
        get :hcard, "guid" => "unknown_guid"
        expect(response).to be_not_found
      end

      it "calls the fetch_person_for_hcard callback" do
        expect_callback(:fetch_person_for_hcard, alice.guid).and_call_original

        get :hcard, "guid" => alice.guid
      end
    end
  end
end
