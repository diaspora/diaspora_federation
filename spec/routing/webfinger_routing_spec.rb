module DiasporaFederation
  describe ReceiveController, type: :routing do
    routes { DiasporaFederation::Engine.routes }

    it "routes GET host-meta" do
      expect(get: ".well-known/host-meta").to route_to(
        controller: "diaspora_federation/webfinger",
        action:     "host_meta"
      )
    end

    it "routes GET webfinger" do
      expect(get: "/.well-known/webfinger").to route_to(
        controller: "diaspora_federation/webfinger",
        action:     "webfinger"
      )
    end
  end
end
