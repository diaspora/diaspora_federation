module DiasporaFederation
  # This namespace contains parsers which are used to deserialize federation entities
  # objects from supported formats (XML, JSON) to objects of DiasporaFederation::Entity
  # classes
  module Parsers
  end
end

require "diaspora_federation/parsers/base_parser"
require "diaspora_federation/parsers/json_parser"
require "diaspora_federation/parsers/xml_parser"
require "diaspora_federation/parsers/relayable_json_parser"
require "diaspora_federation/parsers/relayable_xml_parser"
