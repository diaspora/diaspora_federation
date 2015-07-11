require_dependency "diaspora_federation/application_controller"

module DiasporaFederation
  # this controller handles all webfinger-specific requests
  class WebfingerController < ApplicationController
    # returns the host-meta xml
    #
    # example:
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
    #        <Link rel="lrdd" type="application/xrd+xml" template="https://server.example/webfinger?q={uri}"/>
    #   </XRD>
    #
    # GET /.well-known/host-meta
    def host_meta
      render body: WebfingerController.host_meta_xml, content_type: "application/xrd+xml"
    end

    # @deprecated this is the pre RFC 7033 webfinger
    #
    # example:
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
    #     <Subject>acct:alice@localhost:3000</Subject>
    #     <Alias>http://localhost:3000/people/c8e87290f6a20132963908fbffceb188</Alias>
    #     <Link rel="http://microformats.org/profile/hcard" type="text/html"
    #           href="http://localhost:3000/hcard/users/c8e87290f6a20132963908fbffceb188"/>
    #     <Link rel="http://joindiaspora.com/seed_location" type="text/html" href="http://localhost:3000/"/>
    #     <Link rel="http://joindiaspora.com/guid" type="text/html" href="c8e87290f6a20132963908fbffceb188"/>
    #     <Link rel="http://webfinger.net/rel/profile-page" type="text/html" href="http://localhost:3000/u/alice"/>
    #     <Link rel="http://schemas.google.com/g/2010#updates-from" type="application/atom+xml"
    #           href="http://localhost:3000/public/alice.atom"/>
    #     <Link rel="salmon" href="http://localhost:3000/receive/users/c8e87290f6a20132963908fbffceb188"/>
    #     <Link rel="diaspora-public-key" type="RSA" href="LS0tLS1CRU......"/>
    #   </XRD>
    # GET /webfinger?q=<uri>
    def legacy_webfinger
      person_wf = find_person_webfinger(params[:q]) if params[:q]

      return render nothing: true, status: 404 if person_wf.nil?

      logger.info "webfinger profile request for: #{person_wf.acct_uri}"
      render body: person_wf.to_xml, content_type: "application/xrd+xml"
    end

    private

    # creates the host-meta xml with the configured server_uri and caches it
    # @return [String] XML string
    def self.host_meta_xml
      @host_meta_xml ||= Discovery::HostMeta.from_base_url(DiasporaFederation.server_uri.to_s).to_xml
    end

    def find_person_webfinger(query)
      DiasporaFederation.callbacks.trigger(:person_webfinger_fetch, query.strip.downcase.sub("acct:", ""))
    end
  end
end
