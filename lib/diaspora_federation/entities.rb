module DiasporaFederation
  # This namespace contains all the entities used to encapsulate data that is
  # passed around in the Diaspora* network as part of the federation protocol.
  #
  # All entities must be defined in this namespace. otherwise the XML
  # de-serialization will fail.
  module Entities
  end
end

require "diaspora_federation/entities/profile"
require "diaspora_federation/entities/person"
