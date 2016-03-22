module DiasporaFederation
  # This namespace contains all the entities used to encapsulate data that is
  # passed around in the Diaspora* network as part of the federation protocol.
  #
  # All entities must be defined in this namespace. otherwise the XML
  # de-serialization will fail.
  module Entities
  end
end

# abstract types
require "diaspora_federation/entities/post"
require "diaspora_federation/entities/relayable"

# types
require "diaspora_federation/entities/profile"
require "diaspora_federation/entities/person"
require "diaspora_federation/entities/contact"
require "diaspora_federation/entities/account_deletion"

require "diaspora_federation/entities/participation"
require "diaspora_federation/entities/like"
require "diaspora_federation/entities/comment"
require "diaspora_federation/entities/poll_answer"
require "diaspora_federation/entities/poll"
require "diaspora_federation/entities/poll_participation"

require "diaspora_federation/entities/location"
require "diaspora_federation/entities/photo"
require "diaspora_federation/entities/status_message"
require "diaspora_federation/entities/reshare"

require "diaspora_federation/entities/message"
require "diaspora_federation/entities/conversation"

require "diaspora_federation/entities/retraction"

# deprecated
require "diaspora_federation/entities/request"
require "diaspora_federation/entities/signed_retraction"
require "diaspora_federation/entities/relayable_retraction"
