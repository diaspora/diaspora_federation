module DiasporaFederation
  module Federation
    # this module is for parse and receive entities.
    module Receiver
      # receive a public message
      # @param [String] data message to receive
      # @param [Boolean] legacy use old slap parser
      def self.receive_public(data, legacy=false)
        received_message = if legacy
                             Salmon::Slap.from_xml(data).entity
                           else
                             magic_env_xml = Nokogiri::XML::Document.parse(data).root
                             Salmon::MagicEnvelope.unenvelop(magic_env_xml).payload
                           end
        receive(received_message)
      end

      # receive a private message
      # @param [String] data message to receive
      # @param [OpenSSL::PKey::RSA] recipient_private_key recipient private key to decrypt the message
      # @param [Object] recipient_id the identifier to persist the entity for the correct user,
      #   see +receive_entity+ callback
      # @param [Boolean] legacy use old slap parser
      def self.receive_private(data, recipient_private_key, recipient_id, legacy=false)
        raise ArgumentError, "no recipient key provided" unless recipient_private_key.instance_of?(OpenSSL::PKey::RSA)
        received_message = if legacy
                             Salmon::EncryptedSlap.from_xml(data, recipient_private_key).entity
                           else
                             magic_env_xml = Salmon::EncryptedMagicEnvelope.decrypt(data, recipient_private_key)
                             Salmon::MagicEnvelope.unenvelop(magic_env_xml).payload
                           end
        receive(received_message, recipient_id)
      end

      def self.receive(received_message, recipient_id=nil)
        DiasporaFederation.callbacks.trigger(:receive_entity, received_message, recipient_id)
      end
      private_class_method :receive
    end
  end
end
