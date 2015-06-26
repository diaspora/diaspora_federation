module DiasporaFederation
  describe DiasporaFederation do
    context "validate_config" do
      it "should validate the config" do
        expect(DiasporaFederation).to receive(:validate_class)
        DiasporaFederation.validate_config
      end

      it "should fails if the server_uri is missing" do
        temp = DiasporaFederation.server_uri
        DiasporaFederation.server_uri = nil
        expect { DiasporaFederation.validate_config }.to raise_error ConfigurationError
        DiasporaFederation.server_uri = temp
      end

      it "should fails if the person_class is missing" do
        temp = DiasporaFederation.person_class
        DiasporaFederation.person_class = nil
        expect { DiasporaFederation.validate_config }.to raise_error ConfigurationError
        DiasporaFederation.person_class = temp.to_s
      end
    end
  end
end
