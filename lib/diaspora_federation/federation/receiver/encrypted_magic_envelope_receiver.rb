module DiasporaFederation
  module Federation
    module Receiver
      # Receiver for an encrypted magic envelope
      #
      # @see Salmon::EncryptedMagicEnvelope
      class EncryptedMagicEnvelopeReceiver < MagicEnvelopeReceiver
        # create a new receiver for an encrypted magic envelope
        # @param [String] data the encrypted json with magic envelope xml
        # @param [OpenSSL::PKey::RSA] recipient_private_key recipient private key to decrypt the message
        def initialize(data, recipient_private_key)
          super(data)
          @recipient_private_key = recipient_private_key
        end

        protected

        def magic_env_xml
          Salmon::EncryptedMagicEnvelope.decrypt(@data, @recipient_private_key)
        end
      end
    end
  end
end
