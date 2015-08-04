require_dependency "diaspora_federation/application_controller"

module DiasporaFederation
  # this controller generates the hcard
  class HCardController < ApplicationController
    # returns the hcard of the user
    #
    # GET /hcard/users/:guid
    def hcard
      person_hcard = DiasporaFederation.callbacks.trigger(:fetch_person_for_hcard, params[:guid])

      if person_hcard.nil?
        render nothing: true, status: 404
      else
        logger.info "hcard profile request for: #{person_hcard.nickname}:#{person_hcard.guid}"
        render html: person_hcard.to_html.html_safe
      end
    end
  end
end
