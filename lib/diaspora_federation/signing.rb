module DiasporaFederation
  # this module defines operations of signing an arbitrary hash with an arbitrary key
  module Signing
    extend Logging
    # @param [OpenSSL::PKey::RSA] key An RSA key
    # @return [String] A Base64 encoded signature of #signable_string with key
    def self.sign_with_key(hash, key)
      sig = Base64.strict_encode64(
        key.sign(
          OpenSSL::Digest::SHA256.new,
          signable_string(hash)
        )
      )
      logger.info "event=sign_with_key status=complete guid=#{hash[:guid]}"
      sig
    end

    # Check that signature is a correct signature
    #
    # @param [String] signature The signature to be verified.
    # @param [OpenSSL::PKey::RSA] key An RSA key
    # @return [Boolean]
    def self.verify_signature(hash, signature, key)
      if key.nil?
        logger.warn "event=verify_signature status=abort reason=no_key guid=#{hash[:guid]}"
        return false
      elsif signature.nil?
        logger.warn "event=verify_signature status=abort reason=no_signature guid=#{hash[:guid]}"
        return false
      end

      validity = key.verify(
        OpenSSL::Digest::SHA256.new,
        Base64.decode64(signature),
        signable_string(hash)
      )
      logger.info "event=verify_signature status=complete guid=#{hash[:guid]} validity=#{validity}"
      validity
    end

    private

    def self.signable_string(hash)
      hash.map { |name, value|
        value.to_s unless name.match(/signature/)
      }.compact.join(";")
    end
  end
end
