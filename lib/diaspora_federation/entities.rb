module DiasporaFederation
  # This namespace contains all the entities used to encapsulate data that is
  # passed around in the diaspora* network as part of the federation protocol.
  #
  # All entities must be defined in this namespace. Otherwise the XML
  # de-serialization will fail.
  module Entities
  end
end

require "diaspora_federation/entities/related_entity"

# abstract types
require "diaspora_federation/entities/post"
require "diaspora_federation/entities/signable"
require "diaspora_federation/entities/account_migration/signable"
require "diaspora_federation/entities/relayable"

# types
require "diaspora_federation/entities/profile"
require "diaspora_federation/entities/person"
require "diaspora_federation/entities/contact"
require "diaspora_federation/entities/account_deletion"
require "diaspora_federation/entities/account_migration"

require "diaspora_federation/entities/participation"
require "diaspora_federation/entities/like"
require "diaspora_federation/entities/comment"
require "diaspora_federation/entities/poll_answer"
require "diaspora_federation/entities/poll"
require "diaspora_federation/entities/poll_participation"

require "diaspora_federation/entities/location"

require "diaspora_federation/entities/event"
require "diaspora_federation/entities/event_participation"

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
