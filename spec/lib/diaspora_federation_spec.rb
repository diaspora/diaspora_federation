module DiasporaFederation
  describe DiasporaFederation do
    context "validate_config" do
      it "should validate the config" do
        expect(DiasporaFederation.callbacks).to receive(:definition_complete?).and_return(true)
        DiasporaFederation.validate_config
      end

      it "should fail if the server_uri is missing" do
        temp = DiasporaFederation.server_uri
        DiasporaFederation.server_uri = nil
        expect { DiasporaFederation.validate_config }.to raise_error ConfigurationError,
                                                                     "server_uri: Missing or invalid"
        DiasporaFederation.server_uri = temp
      end

      it "should fail if the certificate_authorities is missing" do
        temp = DiasporaFederation.certificate_authorities
        DiasporaFederation.certificate_authorities = nil
        expect { DiasporaFederation.validate_config }.to raise_error ConfigurationError,
                                                                     "certificate_authorities: Not configured"
        DiasporaFederation.certificate_authorities = temp
      end

      it "should fail if the certificate_authorities is missing" do
        temp = DiasporaFederation.certificate_authorities
        DiasporaFederation.certificate_authorities = "/unknown"
        expect { DiasporaFederation.validate_config }.to raise_error ConfigurationError,
                                                                     "certificate_authorities: File not found: /unknown"
        DiasporaFederation.certificate_authorities = temp
      end

      it "should validate the callbacks" do
        expect(DiasporaFederation.callbacks).to receive(:definition_complete?).and_return(false)
        expect { DiasporaFederation.validate_config }.to raise_error ConfigurationError, "Missing handlers for "
      end
    end
  end
end
