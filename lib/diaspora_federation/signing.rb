module DiasporaFederation
  # this module defines operations of signing an arbitrary hash with an arbitrary key
  module Signing
    extend Logging

    # Sign the data with the key
    #
    # @param [Hash] hash data to sign
    # @param [OpenSSL::PKey::RSA] privkey An RSA key
    # @return [String] A Base64 encoded signature of #signable_string with key
    def self.sign_with_key(hash, privkey)
      sig = Base64.strict_encode64(
        privkey.sign(
          OpenSSL::Digest::SHA256.new,
          signable_string(hash)
        )
      )
      logger.info "event=sign_with_key status=complete guid=#{hash[:guid]}"
      sig
    end

    # Check that signature is a correct signature
    #
    # @param [Hash] hash data to verify
    # @param [String] signature The signature to be verified.
    # @param [OpenSSL::PKey::RSA] pubkey An RSA key
    # @return [Boolean]
    def self.verify_signature(hash, signature, pubkey)
      if pubkey.nil?
        logger.warn "event=verify_signature status=abort reason=no_key guid=#{hash[:guid]}"
        return false
      elsif signature.nil?
        logger.warn "event=verify_signature status=abort reason=no_signature guid=#{hash[:guid]}"
        return false
      end

      validity = pubkey.verify(
        OpenSSL::Digest::SHA256.new,
        Base64.decode64(signature),
        signable_string(hash)
      )
      logger.info "event=verify_signature status=complete guid=#{hash[:guid]} validity=#{validity}"
      validity
    end

    private

    # @param [Hash] hash data to sign
    # @return [String] signature data string
    def self.signable_string(hash)
      hash.map {|name, value|
        value.to_s unless name.match(/signature/)
      }.compact.join(";")
    end
  end
end
