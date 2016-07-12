require_dependency "diaspora_federation/application_controller"

module DiasporaFederation
  # This controller generates the hcard.
  class HCardController < ApplicationController
    # Returns the hcard of the user
    #
    # GET /hcard/users/:guid
    def hcard
      person_hcard = DiasporaFederation.callbacks.trigger(:fetch_person_for_hcard, params[:guid])

      if person_hcard.nil?
        render nothing: true, status: 404
      else
        logger.info "hcard profile request for: #{person_hcard.nickname}:#{person_hcard.guid}"
        # rubocop:disable Rails/OutputSafety
        render html: person_hcard.to_html.html_safe
        # rubocop:enable Rails/OutputSafety
      end
    end
  end
end
