require_dependency "diaspora_federation/application_controller"

module DiasporaFederation
  # this controller generates the hcard
  class HCardController < ApplicationController
    # returns the hcard of the user
    #
    # GET /hcard/users/:guid
    def hcard
      person_hcard = DiasporaFederation.callbacks.trigger(:person_hcard_fetch, params[:guid])

      return render nothing: true, status: 404 if person_hcard.nil?

      logger.info "hcard profile request for: #{person_hcard.nickname}:#{person_hcard.guid}"
      render html: person_hcard.to_html.html_safe
    end
  end
end
