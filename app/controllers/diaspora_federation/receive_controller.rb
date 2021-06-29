# frozen_string_literal: true

require_dependency "diaspora_federation/application_controller"

module DiasporaFederation
  # This controller processes receiving messages.
  class ReceiveController < ApplicationController
    # Receives public messages
    #
    # POST /receive/public
    def public
      data = request.body.read
      logger.debug data

      DiasporaFederation.callbacks.trigger(:queue_public_receive, data)

      head :accepted
    end

    # Receives private messages for a user
    #
    # POST /receive/users/:guid
    def private
      data = request.body.read
      logger.debug data

      success = DiasporaFederation.callbacks.trigger(:queue_private_receive, params[:guid], data)

      head success ? :accepted : :not_found
    end
  end
end
