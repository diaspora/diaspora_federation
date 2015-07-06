require_dependency "diaspora_federation/application_controller"

module DiasporaFederation
  # this controller generates the hcard
  class HCardController < ApplicationController
    # returns the hcard of the user
    #
    # GET /hcard/users/:guid
    def hcard
      person = DiasporaFederation.person_class.find_local_by_guid(params[:guid])

      return render nothing: true, status: 404 if person.nil?

      logger.info "hcard profile request for: #{person.diaspora_handle}"
      render html: WebFinger::HCard.from_person(person).to_html.html_safe
    end
  end
end
