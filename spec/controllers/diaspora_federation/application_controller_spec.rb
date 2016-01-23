module DiasporaFederation
  describe ApplicationController, type: :controller do
    controller do
      def index
        head :ok
      end
    end

    describe "#set_locale" do
      it "sets the default locale" do
        expect(I18n).to receive(:locale=).with(:en)
        get :index
      end
    end
  end
end
