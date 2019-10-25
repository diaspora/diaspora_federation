# frozen_string_literal: true

module DiasporaFederation
  module Federation
    module Receiver
      # Receiver for private entities
      class Private < AbstractReceiver
        private

        def validate
          raise RecipientRequired if recipient_id.nil?

          super
        end
      end
    end
  end
end
