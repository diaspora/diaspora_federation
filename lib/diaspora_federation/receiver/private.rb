module DiasporaFederation

  class Receiver
    # Receiver::Private is used to receive private messages, which are addressed to a specific user, encrypted with his
    # public key and packed using Salmon::EncryptedSlap
    class Private < Receiver
      def initialize(salmon_xml, recipient_private_key)
        super(salmon_xml)
        raise RecipientKeyNotFound if recipient_private_key.nil?
        @recipient_private_key = recipient_private_key
      end

      protected

      def slap
        @salmon ||= Salmon::EncryptedSlap.from_xml(@salmon_xml, @recipient_private_key)
      end
    end
  end
end
