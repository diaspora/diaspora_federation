# frozen_string_literal: true

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

        doc = Nokogiri::XML(slap_xml)

        author_elem = doc.at_xpath("d:diaspora/d:header/d:author_id", Slap::NS)
        raise MissingAuthor if author_elem.nil? || author_elem.content.empty?

        sender = author_elem.content

        MagicEnvelope.unenvelop(magic_env_from_doc(doc), sender)
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
