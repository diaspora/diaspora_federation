module DiasporaFederation
  module Salmon
    # +Slap+ provides class methods to create unencrypted Slap XML from payload
    # data and parse incoming XML into a Slap instance.
    #
    # A diaspora* flavored magic-enveloped XML message looks like the following:
    #
    #   <?xml version="1.0" encoding="UTF-8"?>
    #   <diaspora xmlns="https://joindiaspora.com/protocol" xmlns:me="http://salmon-protocol.org/ns/magic-env">
    #     <header>
    #       <author_id>{author}</author_id>
    #     </header>
    #     {magic_envelope}
    #   </diaspora>
    #
    # @example Generating a Salmon Slap
    #   author_id = "author@pod.example.tld"
    #   author_privkey = however_you_retrieve_the_authors_private_key(author_id)
    #   entity = YourEntity.new(attr: "val")
    #
    #   slap_xml = Slap.generate_xml(author_id, author_privkey, entity)
    #
    # @example Parsing a Salmon Slap
    #   entity = Slap.from_xml(slap_xml).payload
    #
    # @deprecated
    class Slap
      # Namespaces
      NS = {d: Salmon::XMLNS, me: MagicEnvelope::XMLNS}.freeze

      # Parses an unencrypted Salmon XML string and returns a new instance of
      # {MagicEnvelope} with the XML data.
      #
      # @param [String] slap_xml Salmon XML
      #
      # @return [MagicEnvelope] magic envelope instance with payload and sender
      #
      # @raise [ArgumentError] if the argument is not a String
      # @raise [MissingAuthor] if the +author_id+ element is missing from the XML
      # @raise [MissingMagicEnvelope] if the +me:env+ element is missing from the XML
      def self.from_xml(slap_xml)
        raise ArgumentError unless slap_xml.instance_of?(String)
        doc = Nokogiri::XML::Document.parse(slap_xml)

        author_elem = doc.at_xpath("d:diaspora/d:header/d:author_id", Slap::NS)
        raise MissingAuthor if author_elem.nil? || author_elem.content.empty?
        sender = author_elem.content

        MagicEnvelope.unenvelop(magic_env_from_doc(doc), sender)
      end

      # Creates an unencrypted Salmon Slap and returns the XML string.
      #
      # @param [String] author_id diaspora* ID of the author
      # @param [OpenSSL::PKey::RSA] privkey sender private_key for signing the magic envelope
      # @param [Entity] entity payload
      # @return [String] Salmon XML string
      # @raise [ArgumentError] if any of the arguments is not the correct type
      def self.generate_xml(author_id, privkey, entity)
        raise ArgumentError unless author_id.instance_of?(String) &&
                                   privkey.instance_of?(OpenSSL::PKey::RSA) &&
                                   entity.is_a?(Entity)

        build_xml do |xml|
          xml.header {
            xml.author_id(author_id)
          }

          xml.parent << MagicEnvelope.new(entity, author_id).envelop(privkey)
        end
      end

      # Builds the xml for the Salmon Slap.
      #
      # @yield [xml] Invokes the block with the
      #   {http://www.rubydoc.info/gems/nokogiri/Nokogiri/XML/Builder Nokogiri::XML::Builder}
      # @return [String] Slap XML
      def self.build_xml
        Nokogiri::XML::Builder.new(encoding: "UTF-8") {|xml|
          xml.diaspora("xmlns" => Salmon::XMLNS, "xmlns:me" => MagicEnvelope::XMLNS) {
            yield xml
          }
        }.to_xml
      end

      # Parses the magic envelop from the document.
      #
      # @param [Nokogiri::XML::Document] doc Salmon XML Document
      private_class_method def self.magic_env_from_doc(doc)
        doc.at_xpath("d:diaspora/me:env", Slap::NS).tap do |env|
          raise MissingMagicEnvelope if env.nil?
        end
      end
    end
  end
end
