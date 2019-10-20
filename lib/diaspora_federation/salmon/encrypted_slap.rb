# frozen_string_literal: true

require "json"

module DiasporaFederation
  module Salmon
    # +EncryptedSlap+ provides class methods for generating and parsing encrypted
    # Slaps. (In principle the same as {Slap}, but with encryption.)
    #
    # The basic encryption mechanism used here is based on the knowledge that
    # asymmetrical encryption is slow and symmetrical encryption is fast. Keeping in
    # mind that a message we want to de-/encrypt may greatly vary in length,
    # performance considerations must play a part of this scheme.
    #
    # A diaspora*-flavored encrypted magic-enveloped XML message looks like the following:
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <diaspora xmlns="https://joindiaspora.com/protocol" xmlns:me="http://salmon-protocol.org/ns/magic-env">
    #     <encrypted_header>{encrypted_header}</encrypted_header>
    #     {magic_envelope with encrypted data}
    #   </diaspora>
    #
    # The encrypted header is encoded in JSON like this (when in plain text):
    #
    #   {
    #     "aes_key"    => "...",
    #     "ciphertext" => "..."
    #   }
    #
    # +aes_key+ is encrypted using the recipients public key, and contains the AES
    # +key+ and +iv+ used to encrypt the +ciphertext+ also encoded as JSON.
    #
    #   {
    #     "key" => "...",
    #     "iv"  => "..."
    #   }
    #
    # +ciphertext+, once decrypted, contains the +author_id+, +aes_key+ and +iv+
    # relevant to the decryption of the data in the magic_envelope and the
    # verification of its signature.
    #
    # The decrypted cyphertext has this XML structure:
    #
    #   <decrypted_header>
    #     <iv>{iv}</iv>
    #     <aes_key>{aes_key}</aes_key>
    #     <author_id>{author_id}</author_id>
    #   </decrypted_header>
    #
    # Finally, before decrypting the magic envelope payload, the signature should
    # first be verified.
    #
    # @example Parsing a Salmon Slap
    #   recipient_privkey = however_you_retrieve_the_recipients_private_key()
    #   entity = EncryptedSlap.from_xml(slap_xml, recipient_privkey).payload
    #
    # @deprecated
    class EncryptedSlap < Slap
      # Creates a {MagicEnvelope} instance from the data within the given XML string
      # containing an encrypted payload.
      #
      # @param [String] slap_xml encrypted Salmon xml
      # @param [OpenSSL::PKey::RSA] privkey recipient private_key for decryption
      #
      # @return [MagicEnvelope] magic envelope instance with payload and sender
      #
      # @raise [ArgumentError] if any of the arguments is of the wrong type
      # @raise [MissingHeader] if the +encrypted_header+ element is missing in the XML
      # @raise [MissingMagicEnvelope] if the +me:env+ element is missing in the XML
      def self.from_xml(slap_xml, privkey)
        raise ArgumentError unless slap_xml.instance_of?(String) && privkey.instance_of?(OpenSSL::PKey::RSA)

        doc = Nokogiri::XML(slap_xml)

        header_elem = doc.at_xpath("d:diaspora/d:encrypted_header", Slap::NS)
        raise MissingHeader if header_elem.nil?

        header = header_data(header_elem.content, privkey)
        sender = header[:author_id]
        cipher_params = {key: Base64.decode64(header[:aes_key]), iv: Base64.decode64(header[:iv])}

        MagicEnvelope.unenvelop(magic_env_from_doc(doc), sender, cipher_params)
      end

      # Decrypts and reads the data from the encrypted XML header
      # @param [String] data base64 encoded, encrypted header data
      # @param [OpenSSL::PKey::RSA] privkey private key for decryption
      # @return [Hash] { iv: "...", aes_key: "...", author_id: "..." }
      private_class_method def self.header_data(data, privkey)
        header_elem = decrypt_header(data, privkey)
        raise InvalidHeader unless header_elem.name == "decrypted_header"

        iv = header_elem.at_xpath("iv").content
        key = header_elem.at_xpath("aes_key").content
        author_id = header_elem.at_xpath("author_id").content

        {iv: iv, aes_key: key, author_id: author_id}
      end

      # Decrypts the xml header
      # @param [String] data base64 encoded, encrypted header data
      # @param [OpenSSL::PKey::RSA] privkey private key for decryption
      # @return [Nokogiri::XML::Element] header xml document
      private_class_method def self.decrypt_header(data, privkey)
        cipher_header = JSON.parse(Base64.decode64(data))
        key = JSON.parse(privkey.private_decrypt(Base64.decode64(cipher_header["aes_key"])))

        xml = AES.decrypt(cipher_header["ciphertext"], Base64.decode64(key["key"]), Base64.decode64(key["iv"]))
        Nokogiri::XML(xml).root
      end
    end
  end
end
