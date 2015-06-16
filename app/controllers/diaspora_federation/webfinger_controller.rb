require_dependency "diaspora_federation/application_controller"

module DiasporaFederation
  class WebfingerController < ApplicationController
    def host_meta
      render "host_meta", content_type: "application/xrd+xml"
    end

    ##
    # this is the pre RFC 7033 webfinger
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
