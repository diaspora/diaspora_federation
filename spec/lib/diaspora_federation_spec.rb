module DiasporaFederation
  describe DiasporaFederation do
    context "validate_config" do
      it "should validate the config" do
        expect(DiasporaFederation.callbacks).to receive(:definition_complete?).and_return(true)
        DiasporaFederation.validate_config
      end

      it "should fails if the server_uri is missing" do
        temp = DiasporaFederation.server_uri
        DiasporaFederation.server_uri = nil
        expect { DiasporaFederation.validate_config }.to raise_error ConfigurationError, "Missing server_uri"
        DiasporaFederation.server_uri = temp
      end

      it "should validate the config" do
        expect(DiasporaFederation.callbacks).to receive(:definition_complete?).and_return(false)
        expect { DiasporaFederation.validate_config }.to raise_error ConfigurationError, "Missing handlers for "
      end
    end
  end
end
