require_dependency "diaspora_federation/application_controller"
require "diaspora_federation/receiver"

module DiasporaFederation
  # this controller processes receiving messages
  class ReceiveController < ApplicationController
    before_action :check_for_xml

    # receives public messages
    #
    # POST /receive/public
    def public
      logger.info "received a public message"
      xml = CGI.unescape(params[:xml])
      logger.debug xml

      DiasporaFederation.callbacks.trigger(:queue_public_receive, xml)

      render nothing: true, status: 202
    end

    # receives private messages for a user
    #
    # POST /receive/users/:guid
    def private
      logger.info "received a private message for #{params[:guid]}"
      xml = CGI.unescape(params[:xml])
      logger.debug xml

      success = DiasporaFederation.callbacks.trigger(:queue_private_receive, params[:guid], xml)

      render nothing: true, status: success ? 202 : 404
    end

    private

    def check_for_xml
      render nothing: true, status: 422 if params[:xml].nil?
    end
  end
end
