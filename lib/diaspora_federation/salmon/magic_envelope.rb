module DiasporaFederation
  module Salmon
    # Represents a Magic Envelope for Diaspora* federation messages.
    #
    # When generating a Magic Envelope, an instance of this class is created and
    # the contents are specified on initialization. Optionally, the payload can be
    # encrypted ({MagicEnvelope#encrypt!}), before the XML is returned
    # ({MagicEnvelope#envelop}).
    #
    # The generated XML appears like so:
    #
    #   <me:env>
    #     <me:data type="application/xml">{data}</me:data>
    #     <me:encoding>base64url</me:encoding>
    #     <me:alg>RSA-SHA256</me:alg>
    #     <me:sig>{signature}</me:sig>
    #   </me:env>
    #
    # When parsing the XML of an incoming Magic Envelope {MagicEnvelope.unenvelop}
    # is used.
    #
    # @see http://salmon-protocol.googlecode.com/svn/trunk/draft-panzer-magicsig-01.html
    class MagicEnvelope
      # returns the payload (only used for testing purposes)
      attr_reader :payload

      # encoding used for the payload data
      ENCODING = "base64url"

      # algorithm used for signing the payload data
      ALGORITHM = "RSA-SHA256"

      # mime type describing the payload data
      DATA_TYPE = "application/xml"

      # digest instance used for signing
      DIGEST = OpenSSL::Digest::SHA256.new

      # XML namespace url
      XMLNS = "http://salmon-protocol.org/ns/magic-env"

      # Creates a new instance of MagicEnvelope.
      #
      # @param [OpenSSL::PKey::RSA] rsa_privkey private key used for signing
      # @param [Entity] payload Entity instance
      # @raise [ArgumentError] if either argument is not of the right type
      def initialize(rsa_privkey, payload)
        raise ArgumentError unless rsa_privkey.instance_of?(OpenSSL::PKey::RSA) &&
                                   payload.is_a?(Entity)

        @rsa_privkey = rsa_privkey
        @payload = XmlPayload.pack(payload).to_xml.strip
      end

      # Builds the XML structure for the magic envelope, inserts the {ENCODING}
      # encoded data and signs the envelope using {DIGEST}.
      #
      # @param [Nokogiri::XML::Builder] xml Salmon XML builder
      def envelop(xml)
        xml["me"].env {
          xml["me"].data(Base64.urlsafe_encode64(@payload), type: DATA_TYPE)
          xml["me"].encoding(ENCODING)
          xml["me"].alg(ALGORITHM)
          xml["me"].sig(Base64.urlsafe_encode64(signature))
        }
      end

      # Encrypts the payload with a new, random AES cipher and returns the cipher
      # params that were used.
      #
      # This must happen after the MagicEnvelope instance was created and before
      # {MagicEnvelope#envelop} is called.
      #
      # @see AES#generate_key_and_iv
      # @see AES#encrypt
      #
      # @return [Hash] AES key and iv. E.g.: { key: "...", iv: "..." }
      def encrypt!
        AES.generate_key_and_iv.tap do |key|
          @payload = AES.encrypt(@payload, key[:key], key[:iv])
        end
      end

      # Extracts the entity encoded in the magic envelope data, if the signature
      # is valid. If +cipher_params+ is given, also attempts to decrypt the payload first.
      #
      # Does some sanity checking to avoid bad surprises...
      #
      # @see XmlPayload#unpack
      # @see AES#decrypt
      #
      # @param [Nokogiri::XML::Element] magic_env XML root node of a magic envelope
      # @param [OpenSSL::PKey::RSA] rsa_pubkey public key to verify the signature
      # @param [Hash] cipher_params hash containing the key and iv for
      #   AES-decrypting previously encrypted data. E.g.: { iv: "...", key: "..." }
      #
      # @return [Entity] reconstructed entity instance
      #
      # @raise [ArgumentError] if any of the arguments is of invalid type
      # @raise [InvalidEnvelope] if the envelope XML structure is malformed
      # @raise [InvalidSignature] if the signature can't be verified
      # @raise [InvalidEncoding] if the data is wrongly encoded
      # @raise [InvalidAlgorithm] if the algorithm used doesn't match
      def self.unenvelop(magic_env, rsa_pubkey, cipher_params=nil)
        raise ArgumentError unless rsa_pubkey.instance_of?(OpenSSL::PKey::RSA) &&
                                   magic_env.instance_of?(Nokogiri::XML::Element)

        raise InvalidEnvelope unless envelope_valid?(magic_env)
        raise InvalidSignature unless signature_valid?(magic_env, rsa_pubkey)

        raise InvalidEncoding unless encoding_valid?(magic_env)
        raise InvalidAlgorithm unless algorithm_valid?(magic_env)

        data = read_and_decrypt_data(magic_env, cipher_params)

        XmlPayload.unpack(Nokogiri::XML::Document.parse(data).root)
      end

      private

      # create the signature for all fields according to specification
      #
      # @return [String] the signature
      def signature
        subject = self.class.sig_subject([@payload,
                                          DATA_TYPE,
                                          ENCODING,
                                          ALGORITHM])
        @rsa_privkey.sign(DIGEST, subject)
      end

      # @param [Nokogiri::XML::Element] env magic envelope XML
      def self.envelope_valid?(env)
        (env.instance_of?(Nokogiri::XML::Element) &&
          env.name == "env" &&
          !env.at_xpath("me:data").content.empty? &&
          !env.at_xpath("me:encoding").content.empty? &&
          !env.at_xpath("me:alg").content.empty? &&
          !env.at_xpath("me:sig").content.empty?)
      end
      private_class_method :envelope_valid?

      # @param [Nokogiri::XML::Element] env magic envelope XML
      # @param [OpenSSL::PKey::RSA] pubkey public key
      # @return [Boolean]
      def self.signature_valid?(env, pubkey)
        subject = sig_subject([Base64.urlsafe_decode64(env.at_xpath("me:data").content),
                               env.at_xpath("me:data")["type"],
                               env.at_xpath("me:encoding").content,
                               env.at_xpath("me:alg").content])

        sig = Base64.urlsafe_decode64(env.at_xpath("me:sig").content)
        pubkey.verify(DIGEST, sig, subject)
      end
      private_class_method :signature_valid?

      # constructs the signature subject.
      # the given array should consist of the data, data_type (mimetype), encoding
      # and the algorithm
      # @param [Array<String>] data_arr
      # @return [String] signature subject
      def self.sig_subject(data_arr)
        data_arr.map {|i| Base64.urlsafe_encode64(i) }.join(".")
      end

      # @param [Nokogiri::XML::Element] magic_env magic envelope XML
      # @return [Boolean]
      def self.encoding_valid?(magic_env)
        magic_env.at_xpath("me:encoding").content == ENCODING
      end
      private_class_method :encoding_valid?

      # @param [Nokogiri::XML::Element] magic_env magic envelope XML
      # @return [Boolean]
      def self.algorithm_valid?(magic_env)
        magic_env.at_xpath("me:alg").content == ALGORITHM
      end
      private_class_method :algorithm_valid?

      # @param [Nokogiri::XML::Element] magic_env magic envelope XML
      # @param [Hash] cipher_params hash containing the key and iv
      # @return [String] data
      def self.read_and_decrypt_data(magic_env, cipher_params)
        data = Base64.urlsafe_decode64(magic_env.at_xpath("me:data").content)
        data = AES.decrypt(data, cipher_params[:key], cipher_params[:iv]) unless cipher_params.nil?
        data
      end
      private_class_method :read_and_decrypt_data
    end
  end
end
