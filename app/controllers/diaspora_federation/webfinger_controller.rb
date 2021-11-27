# frozen_string_literal: true

require_dependency "diaspora_federation/application_controller"

module DiasporaFederation
  # This controller handles all webfinger-specific requests.
  class WebfingerController < ApplicationController
    # Returns the webfinger as RFC 7033 JRD or XRD.
    #
    # JSON example:
    #   {
    #     "subject": "acct:alice@localhost:3000",
    #     "aliases": [
    #       "http://localhost:3000/people/c8e87290f6a20132963908fbffceb188"
    #     ],
    #     "links": [
    #       {
    #         "rel": "http://microformats.org/profile/hcard",
    #         "type": "text/html",
    #         "href": "http://localhost:3000/hcard/users/c8e87290f6a20132963908fbffceb188"
    #       },
    #       {
    #         "rel": "http://joindiaspora.com/seed_location",
    #         "type": "text/html",
    #         "href": "http://localhost:3000/"
    #       },
    #       {
    #         "rel": "http://webfinger.net/rel/profile-page",
    #         "type": "text/html",
    #         "href": "http://localhost:3000/u/alice"
    #       },
    #       {
    #         "rel": "http://schemas.google.com/g/2010#updates-from",
    #         "type": "application/atom+xml",
    #         "href": "http://localhost:3000/public/alice.atom"
    #       },
    #       {
    #         "rel": "salmon",
    #         "href": "http://localhost:3000/receive/users/c8e87290f6a20132963908fbffceb188"
    #       },
    #       {
    #         "rel": "http://ostatus.org/schema/1.0/subscribe",
    #         "template": "http://localhost:3000/people?q={uri}"
    #       }
    #     ]
    #   }
    #
    # GET /.well-known/webfinger?resource=<uri>
    def webfinger
      person_wf = find_person_webfinger(params.require(:resource))

      if person_wf.nil?
        head :not_found
      else
        logger.info "Webfinger profile request for: #{person_wf.acct_uri}"

        headers["Access-Control-Allow-Origin"] = "*"
        render json: JSON.pretty_generate(person_wf.to_json), content_type: "application/jrd+json"
      end
    end

    private

    def find_person_webfinger(query)
      DiasporaFederation.callbacks.trigger(:fetch_person_for_webfinger, query.strip.downcase.sub("acct:", ""))
    end
  end
end
