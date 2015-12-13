module DiasporaFederation
  # SenderNotFound is raised when failed to fetch a public key of the sender of the received message
  class SenderNotFound < Exception
  end

  # Common base for Private and Public receivers
  #   @see Receiver::Public
  #   @see Receiver::Private
  class Receiver
    def initialize(salmon_xml)
      @salmon_xml = salmon_xml
    end

    def receive!
      sender_id = slap.author_id
      pkey = DiasporaFederation.callbacks.trigger(:fetch_public_key_by_diaspora_id, sender_id)
      raise SenderNotFound if pkey.nil?
      DiasporaFederation.callbacks.trigger(:entity_persist, slap.entity(pkey), @recipient_guid, sender_id)
    end
  end
end

require "diaspora_federation/receiver/private"
require "diaspora_federation/receiver/public"
