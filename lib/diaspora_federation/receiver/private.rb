module DiasporaFederation
  # RecipientNotFound is raised when failed to fetch a private key of the recipient of the received message
  class RecipientNotFound < Exception
  end

  class Receiver
    # Receiver::Private is used to receive private messages, which are addressed to a specific user, encrypted with his
    # public key and packed using Salmon::EncryptedSlap
    class Private < Receiver
      def initialize(recipient_guid, salmon_xml)
        super(salmon_xml)
        @recipient_guid = recipient_guid
        @recipient_private_key = DiasporaFederation.callbacks.trigger(:fetch_private_key_by_user_guid, recipient_guid)
        raise RecipientNotFound if @recipient_private_key.nil?
      end

      protected

      def slap
        @salmon ||= Salmon::EncryptedSlap.from_xml(@salmon_xml, @recipient_private_key)
      end
    end
  end
end
