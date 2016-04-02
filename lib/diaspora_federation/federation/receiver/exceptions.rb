module DiasporaFederation
  module Federation
    module Receiver
      # Raised, if the sender of the {Salmon::MagicEnvelope} is not allowed to send the entity.
      class InvalidSender < RuntimeError
      end

      # Raised, if receiving a private message without recipient.
      class RecipientRequired < RuntimeError
      end

      # Raised, if receiving a message with public receiver which is not public but should be.
      class NotPublic < RuntimeError
      end
    end
  end
end
