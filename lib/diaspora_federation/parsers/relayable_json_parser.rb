# frozen_string_literal: true

module DiasporaFederation
  module Parsers
    # This is a parser of JSON serialized object, that is normally used for parsing data of relayables.
    # Assumed format differs from the usual entity by additional "property_order" property which is used to
    # compute signatures deterministically.
    # Input JSON for this parser is expected to match "/definitions/relayable" subschema of the JSON schema at
    # https://diaspora.github.io/diaspora_federation/schemas/federation_entities.json.
    class RelayableJsonParser < JsonParser
      # @see JsonParser#parse
      # @see BaseParser#parse
      # @return [Array[2]] comprehensive data for an entity instantiation
      def parse(json_hash)
        super.push(json_hash["property_order"])
      end

      private

      def from_json_sanity_validation(json_hash)
        super
        return unless json_hash["property_order"].nil?

        raise DeserializationError, "Required property is missing in JSON object: property_order"
      end
    end
  end
end
