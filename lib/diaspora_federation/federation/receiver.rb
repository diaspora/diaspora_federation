module DiasporaFederation
  module Federation
    # Common base for Private and Public receivers
    #   @see Receiver::Public
    #   @see Receiver::Private
    class Receiver
      # initializes a new Receiver for a salmon XML
      # @param [String] salmon_xml the message salmon xml
      def initialize(salmon_xml)
        @salmon_xml = salmon_xml
      end

      # Parse the salmon xml and send it to the +:save_entity_after_receive+ callback
      def receive!
        sender_id = slap.author_id
        public_key = DiasporaFederation.callbacks.trigger(:fetch_public_key_by_diaspora_id, sender_id)
        raise SenderKeyNotFound if public_key.nil?
        DiasporaFederation.callbacks.trigger(:save_entity_after_receive, slap.entity(public_key))
      end
    end
  end
end

require "diaspora_federation/federation/receiver/private"
require "diaspora_federation/federation/receiver/public"
