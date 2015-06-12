require_dependency "diaspora_federation/application_controller"

module DiasporaFederation
  class ReceiveController < ApplicationController
    before_action :check_for_xml, only: %i(public private)

    def public
      Rails.logger.info "received a public message"
      Rails.logger.info CGI.unescape(params[:xml])
      render nothing: true, status: :ok
    end

    def private
      Rails.logger.info "received a private message for #{params[:guid]}"
      Rails.logger.info CGI.unescape(params[:xml])
      render nothing: true, status: :ok
    end

    private

    def check_for_xml
      render nothing: true, status: 422 if params[:xml].nil?
    end
  end
end
