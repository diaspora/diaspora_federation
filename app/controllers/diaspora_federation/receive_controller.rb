require_dependency "diaspora_federation/application_controller"

module DiasporaFederation
  # This controller processes receiving messages.
  class ReceiveController < ApplicationController
    before_action :check_for_xml

    # Receives public messages
    #
    # POST /receive/public
    def public
      legacy = request.content_type != "application/magic-envelope+xml"

      data = data_for_public_message(legacy)
      logger.debug data

      DiasporaFederation.callbacks.trigger(:queue_public_receive, data, legacy)

      head :accepted
    end

    # Receives private messages for a user
    #
    # POST /receive/users/:guid
    def private
      legacy = request.content_type != "application/json"

      data = data_for_private_message(legacy)
      logger.debug data

      success = DiasporaFederation.callbacks.trigger(:queue_private_receive, params[:guid], data, legacy)

      head success ? :accepted : :not_found
    end

    private

    # Checks the xml parameter for legacy salmon slaps
    # @deprecated
    def check_for_xml
      legacy_request = request.content_type.nil? || request.content_type == "application/x-www-form-urlencoded"
      head :unprocessable_entity if params[:xml].nil? && legacy_request
    end

    def data_for_public_message(legacy)
      if legacy
        logger.info "received a public salmon slap"
        CGI.unescape(params[:xml])
      else
        logger.info "received a public magic envelope"
        request.body.read
      end
    end

    def data_for_private_message(legacy)
      if legacy
        logger.info "received a private salmon slap for #{params[:guid]}"
        CGI.unescape(params[:xml])
      else
        logger.info "received a private encrypted magic envelope for #{params[:guid]}"
        request.body.read
      end
    end
  end
end
