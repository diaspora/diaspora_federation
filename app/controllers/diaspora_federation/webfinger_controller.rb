require_dependency "diaspora_federation/application_controller"

module DiasporaFederation
  class WebfingerController < ApplicationController
    def host_meta
      render "host_meta", content_type: "application/xrd+xml"
    end

    ##
    # this is the pre RFC 7033 webfinger
    def legacy_webfinger
      @person = Person.find_local_by_diaspora_handle(params[:q].strip.downcase.gsub("acct:", "")) if params[:q]

      return render nothing: true, status: 404 if @person.nil?

      logger.info "webfinger profile request for: #{@person.diaspora_handle}"
      render "webfinger", content_type: "application/xrd+xml"
    end
  end
end
