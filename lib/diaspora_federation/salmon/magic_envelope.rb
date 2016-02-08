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
    #     <me:sig key_id="{sender}">{signature}</me:sig>
    #   </me:env>
    #
    # When parsing the XML of an incoming Magic Envelope {MagicEnvelope.unenvelop}
    # is used.
    #
    # @see http://salmon-protocol.googlecode.com/svn/trunk/draft-panzer-magicsig-01.html
    class MagicEnvelope
      # encoding used for the payload data
      ENCODING = "base64url".freeze

      # algorithm used for signing the payload data
      ALGORITHM = "RSA-SHA256".freeze

      # mime type describing the payload data
      DATA_TYPE = "application/xml".freeze

      # digest instance used for signing
      DIGEST = OpenSSL::Digest::SHA256.new

      # XML namespace url
      XMLNS = "http://salmon-protocol.org/ns/magic-env".freeze

      # Creates a new instance of MagicEnvelope.
      #
      # @param [Entity] payload Entity instance
      # @raise [ArgumentError] if either argument is not of the right type
      def initialize(payload)
        raise ArgumentError unless payload.is_a?(Entity)

        @payload = XmlPayload.pack(payload).to_xml.strip
      end

      # Builds the XML structure for the magic envelope, inserts the {ENCODING}
      # encoded data and signs the envelope using {DIGEST}.
      #
      # @param [OpenSSL::PKey::RSA] privkey private key used for signing
      # @param [String] sender_id diaspora-ID of the sender
      # @return [Nokogiri::XML::Element] XML root node
      def envelop(privkey, sender_id)
        raise ArgumentError unless privkey.instance_of?(OpenSSL::PKey::RSA) && sender_id.is_a?(String)

        build_xml {|xml|
          xml["me"].env("xmlns:me" => XMLNS) {
            xml["me"].data(Base64.urlsafe_encode64(@payload), type: DATA_TYPE)
            xml["me"].encoding(ENCODING)
            xml["me"].alg(ALGORITHM)
            xml["me"].sig(Base64.urlsafe_encode64(sign(privkey)), key_id: Base64.urlsafe_encode64(sender_id))
          }
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
        raise ArgumentError unless magic_env.instance_of?(Nokogiri::XML::Element) &&
                                   rsa_pubkey.instance_of?(OpenSSL::PKey::RSA)

        raise InvalidEnvelope unless envelope_valid?(magic_env)
        raise InvalidSignature unless signature_valid?(magic_env, rsa_pubkey)

        raise InvalidEncoding unless encoding_valid?(magic_env)
        raise InvalidAlgorithm unless algorithm_valid?(magic_env)

        data = read_and_decrypt_data(magic_env, cipher_params)

        XmlPayload.unpack(Nokogiri::XML::Document.parse(data).root)
      end

      private

      # Builds the xml root node of the magic envelope.
      #
      # @yield [xml] Invokes the block with the
      #   {http://www.rubydoc.info/gems/nokogiri/Nokogiri/XML/Builder Nokogiri::XML::Builder}
      # @return [Nokogiri::XML::Element] XML root node
      def build_xml
        Nokogiri::XML::Builder.new(encoding: "UTF-8") {|xml|
          yield xml
        }.doc.root
      end

      # create the signature for all fields according to specification
      #
      # @param [OpenSSL::PKey::RSA] privkey private key used for signing
      # @return [String] the signature
      def sign(privkey)
        subject = MagicEnvelope.send(:sig_subject, [@payload, DATA_TYPE, ENCODING, ALGORITHM])
        privkey.sign(DIGEST, subject)
      end

      # @param [Nokogiri::XML::Element] env magic envelope XML
      def self.envelope_valid?(env)
        (env.instance_of?(Nokogiri::XML::Element) &&
          env.name == "env" &&
          !env.at_xpath("me:data").content.empty? &&
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
      private_class_method :sig_subject

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
