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
      # @param rsa_pkey [OpenSSL::PKey::RSA] private key used for signing
      # @param payload [Entity] Entity instance
      # @param parent_node [Nokogiri::XML::Element] parent element for insering in XML document
      # @raise [ArgumentError] if either argument is not of the right type
      def initialize(rsa_pkey, payload, parent_node=nil)
        raise ArgumentError unless rsa_pkey.instance_of?(OpenSSL::PKey::RSA) &&
                                   payload.is_a?(Entity)

        if parent_node.nil?
          doc = Nokogiri::XML::Document.new
          parent_node = Nokogiri::XML::Element.new("root", doc)
          parent_node.add_namespace("me", XMLNS)
          doc.root = parent_node
        end

        @parent_node = parent_node
        @rsa_pkey = rsa_pkey
        @payload = XmlPayload.pack(payload).to_xml.strip
      end

      # Builds the XML structure for the magic envelope, inserts the {ENCODING}
      # encoded data and signs the envelope using {DIGEST}.
      #
      # @return [Nokogiri::XML::Element] XML root node
      def envelop
        builder = Nokogiri::XML::Builder.with(@parent_node) do |xml|
          xml["me"].env {
            xml["me"].data(Base64.urlsafe_encode64(@payload), type: DATA_TYPE)
            xml["me"].encoding(ENCODING)
            xml["me"].alg(ALGORITHM)
            xml["me"].sig(Base64.urlsafe_encode64(signature))
          }
        end

        builder.doc.at_xpath("//me:env")
      end

      # Encrypts the payload with a new, random AES cipher and returns the cipher
      # params that were used.
      #
      # This must happen after the MagicEnvelope instance was created and before
      # {MagicEnvelope#envelop} is called.
      #
      # @see Salmon.aes_encrypt
      #
      # @return [Hash] AES key and iv. E.g.: { key: "...", iv: "..." }
      def encrypt!
        encryption_data = AES.encrypt(@payload)
        @payload = encryption_data[:ciphertext]

        {key: encryption_data[:key], iv: encryption_data[:iv]}
      end

      # Extracts the entity encoded in the magic envelope data, if the signature
      # is valid. If +cipher_params+ is given, also attempts to decrypt the payload first.
      #
      # Does some sanity checking to avoid bad surprises...
      #
      # @see XmlPayload.unpack
      # @see Salmon.aes_decrypt
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

        enc = magic_env.at_xpath("me:encoding").content
        alg = magic_env.at_xpath("me:alg").content

        raise InvalidEncoding unless enc == ENCODING
        raise InvalidAlgorithm unless alg == ALGORITHM

        data = Base64.urlsafe_decode64(magic_env.at_xpath("me:data").content)
        unless cipher_params.nil?
          data = AES.decrypt(data, cipher_params[:key], cipher_params[:iv])
        end

        XmlPayload.unpack(Nokogiri::XML::Document.parse(data).root)
      end

      private

      # create the signature for all fields according to specification
      def signature
        subject = self.class.sig_subject([@payload,
                                          DATA_TYPE,
                                          ENCODING,
                                          ALGORITHM])
        @rsa_pkey.sign(DIGEST, subject)
      end

      # @param [Nokogiri::XML::Element]
      def self.envelope_valid?(env)
        (env.instance_of?(Nokogiri::XML::Element) &&
          env.name == "env" &&
          !env.at_xpath("me:data").content.empty? &&
          !env.at_xpath("me:encoding").content.empty? &&
          !env.at_xpath("me:alg").content.empty? &&
          !env.at_xpath("me:sig").content.empty?)
      end
      private_class_method :envelope_valid?

      # @param [Nokogiri::XML::Element]
      # @param [OpenSSL::PKey::RSA] public_key
      def self.signature_valid?(env, pkey)
        subject = sig_subject([Base64.urlsafe_decode64(env.at_xpath("me:data").content),
                               env.at_xpath("me:data")["type"],
                               env.at_xpath("me:encoding").content,
                               env.at_xpath("me:alg").content])

        sig = Base64.urlsafe_decode64(env.at_xpath("me:sig").content)
        pkey.verify(DIGEST, sig, subject)
      end
      private_class_method :signature_valid?

      # constructs the signature subject.
      # the given array should consist of the data, data_type (mimetype), encoding
      # and the algorithm
      # @param [Array<String>]
      def self.sig_subject(data_arr)
        data_arr.map {|i| Base64.urlsafe_encode64(i) }.join(".")
      end
    end
  end
end
