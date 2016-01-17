module DiasporaFederation
  module Federation
    class Receiver
      # Receiver::Private is used to receive private messages, which are addressed
      # to a specific user, encrypted with his public key and packed using Salmon::EncryptedSlap
      class Private < Receiver
        # initializes a new Private Receiver for a salmon XML
        # @param [String] salmon_xml the message salmon xml
        # @param [OpenSSL::PKey::RSA] recipient_private_key recipient private key to decrypt the message
        def initialize(salmon_xml, recipient_private_key)
          super(salmon_xml)
          raise RecipientKeyNotFound if recipient_private_key.nil?
          @recipient_private_key = recipient_private_key
        end

        protected

        # parses the encrypted slap xml
        # @return [Salmon::EncryptedSlap] slap instance
        def slap
          @salmon ||= Salmon::EncryptedSlap.from_xml(@salmon_xml, @recipient_private_key)
        end
      end
    end
  end
end
