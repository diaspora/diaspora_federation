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
      logger.debug CGI.unescape(params[:xml])
      Receiver::Public.new(CGI.unescape(params[:xml])).receive!
      render nothing: true, status: :ok
    end

    # receives private messages for a user
    #
    # POST /receive/users/:guid
    def private
      logger.info "received a private message for #{params[:guid]}"
      logger.debug CGI.unescape(params[:xml])
      begin
        Receiver::Private.new(params[:guid], CGI.unescape(params[:xml])).receive!
        render nothing: true, status: :ok
      rescue RecipientNotFound
        render nothing: true, status: 404
      end
    end

    private

    def check_for_xml
      render nothing: true, status: 422 if params[:xml].nil?
    end
  end
end
