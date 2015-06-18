require_dependency "diaspora_federation/application_controller"

module DiasporaFederation
  ##
  # this controller handles all webfinger-specific requests
  class WebfingerController < ApplicationController
    ##
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
      doc = WebFinger::HostMeta.from_base_url(DiasporaFederation.server_uri.to_s)
      render body: doc.to_xml, content_type: "application/xrd+xml"
    end

    ##
    # this is the pre RFC 7033 webfinger
    #
    # GET /webfinger?q={uri}
    def legacy_webfinger
      @person = find_person(params[:q]) if params[:q]

      return render nothing: true, status: 404 if @person.nil?

      logger.info "webfinger profile request for: #{@person.diaspora_handle}"
      render "webfinger", content_type: "application/xrd+xml"
    end

    private

    def find_person(query)
      DiasporaFederation.person_class.find_local_by_diaspora_handle(query.strip.downcase.gsub("acct:", ""))
    end
  end
end
