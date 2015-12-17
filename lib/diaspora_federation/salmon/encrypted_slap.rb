require "json"

module DiasporaFederation
  module Salmon
    # +EncryptedSlap+ provides class methods for generating and parsing encrypted
    # Slaps. (In principle the same as  {Slap}, but with encryption.)
    #
    # The basic encryption mechanism used here is based on the knowledge that
    # asymmetrical encryption is slow and symmetrical encryption is fast. Keeping in
    # mind that a message we want to de-/encrypt may greatly vary in length,
    # performance considerations must play a part of this scheme.
    #
    # A Diaspora*-flavored encrypted magic-enveloped XML message looks like the following:
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
    # @example Generating an encrypted Salmon Slap
    #   author_id = "author@pod.example.tld"
    #   author_privkey = however_you_retrieve_the_authors_private_key(author_id)
    #   recipient_pubkey = however_you_retrieve_the_recipients_public_key()
    #   entity = YourEntity.new(attr: "val")
    #
    #   slap_xml = EncryptedSlap.generate_xml(author_id, author_privkey, entity, recipient_pubkey)
    #
    # @example Parsing a Salmon Slap
    #   recipient_privkey = however_you_retrieve_the_recipients_private_key()
    #   slap = EncryptedSlap.from_xml(slap_xml, recipient_privkey)
    #   author_pubkey = however_you_retrieve_the_authors_public_key(slap.author_id)
    #
    #   entity = slap.entity(author_pubkey)
    #
    class EncryptedSlap
      # Creates a Slap instance from the data within the given XML string
      # containing an encrypted payload.
      #
      # @param [String] slap_xml encrypted Salmon xml
      # @param [OpenSSL::PKey::RSA] pkey recipient private_key for decryption
      #
      # @return [Slap] new Slap instance
      #
      # @raise [ArgumentError] if any of the arguments is of the wrong type
      # @raise [MissingHeader] if the +encrypted_header+ element is missing in the XML
      # @raise [MissingMagicEnvelope] if the +me:env+ element is missing in the XML
      def self.from_xml(slap_xml, pkey)
        raise ArgumentError unless slap_xml.instance_of?(String) && pkey.instance_of?(OpenSSL::PKey::RSA)
        doc = Nokogiri::XML::Document.parse(slap_xml)

        Slap.new.tap do |slap|
          header_elem = doc.at_xpath("d:diaspora/d:encrypted_header", Slap::NS)
          raise MissingHeader if header_elem.nil?
          header = header_data(header_elem.content, pkey)
          slap.author_id = header[:author_id]
          slap.cipher_params = {key: Base64.decode64(header[:aes_key]), iv: Base64.decode64(header[:iv])}

          slap.add_magic_env_from_doc(doc)
        end
      end

      # Creates an encrypted Salmon Slap and returns the XML string.
      #
      # @param [String] author_id Diaspora* handle of the author
      # @param [OpenSSL::PKey::RSA] pkey sender private key for signing the magic envelope
      # @param [Entity] entity payload
      # @param [OpenSSL::PKey::RSA] pubkey recipient public key for encrypting the AES key
      # @return [String] Salmon XML string
      # @raise [ArgumentError] if any of the arguments is of the wrong type
      def self.generate_xml(author_id, pkey, entity, pubkey)
        raise ArgumentError unless author_id.instance_of?(String) &&
                                   pkey.instance_of?(OpenSSL::PKey::RSA) &&
                                   entity.is_a?(Entity) &&
                                   pubkey.instance_of?(OpenSSL::PKey::RSA)

        Slap.build_xml do |xml|
          magic_envelope = MagicEnvelope.new(pkey, entity)
          envelope_key = magic_envelope.encrypt!

          encrypted_header(author_id, envelope_key, pubkey, xml)
          magic_envelope.envelop(xml)
        end
      end

      # decrypts and reads the data from the encrypted XML header
      # @param [String] data base64 encoded, encrypted header data
      # @param [OpenSSL::PKey::RSA] pkey private key for decryption
      # @return [Hash] { iv: "...", aes_key: "...", author_id: "..." }
      def self.header_data(data, pkey)
        header_elem = decrypt_header(data, pkey)
        raise InvalidHeader unless header_elem.name == "decrypted_header"

        iv = header_elem.at_xpath("iv").content
        key = header_elem.at_xpath("aes_key").content
        author_id = header_elem.at_xpath("author_id").content

        {iv: iv, aes_key: key, author_id: author_id}
      end
      private_class_method :header_data

      # decrypts the xml header
      # @param [String] data base64 encoded, encrypted header data
      # @param [OpenSSL::PKey::RSA] pkey private key for decryption
      # @return [Nokogiri::XML::Element] header xml document
      def self.decrypt_header(data, pkey)
        cipher_header = JSON.parse(Base64.decode64(data))
        key = JSON.parse(pkey.private_decrypt(Base64.decode64(cipher_header["aes_key"])))

        xml = AES.decrypt(cipher_header["ciphertext"], Base64.decode64(key["key"]), Base64.decode64(key["iv"]))
        Nokogiri::XML::Document.parse(xml).root
      end
      private_class_method :decrypt_header

      # encrypt the header xml with an AES cipher and encrypt the cipher params
      # with the recipients public_key
      # @param [String] author_id diaspora_handle
      # @param [Hash] envelope_key envelope cipher params
      # @param [OpenSSL::PKey::RSA] pubkey recipient public_key
      # @param [Nokogiri::XML::Element] xml parent element for inserting in XML document
      def self.encrypted_header(author_id, envelope_key, pubkey, xml)
        data = header_xml(author_id, strict_base64_encode(envelope_key))
        key = AES.generate_key_and_iv
        ciphertext = AES.encrypt(data, key[:key], key[:iv])

        json_key = JSON.generate(strict_base64_encode(key))
        encrypted_key = Base64.strict_encode64(pubkey.public_encrypt(json_key))

        json_header = JSON.generate(aes_key: encrypted_key, ciphertext: ciphertext)

        xml.encrypted_header(Base64.strict_encode64(json_header))
      end
      private_class_method :encrypted_header

      # generate the header xml string, including the author, aes_key and iv
      # @param [String] author_id diaspora_handle of the author
      # @param [Hash] envelope_key { key: "...", iv: "..." } (values in base64)
      # @return [String] header XML string
      def self.header_xml(author_id, envelope_key)
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.decrypted_header {
            xml.iv(envelope_key[:iv])
            xml.aes_key(envelope_key[:key])
            xml.author_id(author_id)
          }
        end
        builder.to_xml.strip
      end
      private_class_method :header_xml

      # @param [Hash] hash { key: "...", iv: "..." }
      # @return [Hash] encoded hash: { key: "...", iv: "..." }
      def self.strict_base64_encode(hash)
        Hash[hash.map {|k, v| [k, Base64.strict_encode64(v)] }]
      end
      private_class_method :strict_base64_encode
    end
  end
end
