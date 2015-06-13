require_dependency "diaspora_federation/application_controller"

module DiasporaFederation
  class ReceiveController < ApplicationController
    before_action :check_for_xml

    def public
      logger.info "received a public message"
      logger.debug CGI.unescape(params[:xml])
      render nothing: true, status: :ok
    end

    def private
      logger.info "received a private message for #{params[:guid]}"
      logger.debug CGI.unescape(params[:xml])
      render nothing: true, status: :ok
    end

    private

    def check_for_xml
      render nothing: true, status: 422 if params[:xml].nil?
    end
  end
end
