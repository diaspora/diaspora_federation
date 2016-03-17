module DiasporaFederation
  module Federation
    module Receiver
      # This is used to receive private messages, which are addressed to a specific user,
      # encrypted with his public key and packed using {Salmon::EncryptedSlap}.
      # @deprecated
      class PrivateSlapReceiver < SlapReceiver
        # initializes a new Private Receiver for a salmon slap XML
        # @param [String] slap_xml the message salmon slap xml
        # @param [OpenSSL::PKey::RSA] recipient_private_key recipient private key to decrypt the message
        def initialize(slap_xml, recipient_private_key)
          super(slap_xml)
          @recipient_private_key = recipient_private_key
        end

        protected

        # parses the encrypted slap xml
        # @return [Salmon::EncryptedSlap] slap instance
        def slap
          @slap ||= Salmon::EncryptedSlap.from_xml(@slap_xml, @recipient_private_key)
        end
      end
    end
  end
end
