# frozen_string_literal: true

module DiasporaFederation
  module Parsers
    # This is a parser of XML serialized object that is normally used for parsing data of relayables.
    # Explanations about the XML data format can be found
    # {https://diaspora.github.io/diaspora_federation/federation/xml_serialization.html here}.
    # Specific features of relayables are described
    # {https://diaspora.github.io/diaspora_federation/federation/relayable.html here}.
    #
    # @see https://diaspora.github.io/diaspora_federation/federation/xml_serialization.html XML Serialization
    #   documentation
    # @see https://diaspora.github.io/diaspora_federation/federation/relayable.html Relayable documentation
    class RelayableXmlParser < XmlParser
      # @see XmlParser#parse
      # @see BaseParser#parse
      # @return [Array[2]] comprehensive data for an entity instantiation
      def parse(*args)
        hash = super[0]
        [hash, hash.keys]
      end
    end
  end
end
