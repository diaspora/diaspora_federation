module DiasporaFederation
  module Federation
    # this module is for parse and receive entities.
    module Receiver
      # receive a public message
      # @param [String] data message to receive
      # @param [Boolean] legacy use old slap parser
      def self.receive_public(data, legacy=false)
        receiver = legacy ? PublicSlapReceiver.new(data) : MagicEnvelopeReceiver.new(data)
        receive(receiver)
      end

      # receive a private message
      # @param [String] data message to receive
      # @param [OpenSSL::PKey::RSA] recipient_private_key recipient private key to decrypt the message
      # @param [Object] recipient_id the identifier to persist the entity for the correct user,
      #   see +receive_entity+ callback
      # @param [Boolean] legacy use old slap parser
      def self.receive_private(data, recipient_private_key, recipient_id, legacy=false)
        raise ArgumentError, "no recipient key provided" unless recipient_private_key.instance_of?(OpenSSL::PKey::RSA)
        receiver = if legacy
                     PrivateSlapReceiver.new(data, recipient_private_key)
                   else
                     EncryptedMagicEnvelopeReceiver.new(data, recipient_private_key)
                   end
        receive(receiver, recipient_id)
      end

      def self.receive(receiver, recipient_id=nil)
        entity = receiver.parse
        DiasporaFederation.callbacks.trigger(:receive_entity, entity, recipient_id)
      end
      private_class_method :receive
    end
  end
end

require "diaspora_federation/federation/receiver/slap_receiver"
require "diaspora_federation/federation/receiver/private_slap_receiver"
require "diaspora_federation/federation/receiver/public_slap_receiver"
require "diaspora_federation/federation/receiver/magic_envelope_receiver"
require "diaspora_federation/federation/receiver/encrypted_magic_envelope_receiver"
