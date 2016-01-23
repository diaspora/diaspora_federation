module DiasporaFederation
  # Base-Controller for all DiasporaFederation-Controller
  class ApplicationController < ActionController::Base
    before_action :set_locale

    # Fix locale leakage from other requests.
    # Set "en" as locale for every federation request.
    def set_locale
      I18n.locale = :en
    end
  end
end
