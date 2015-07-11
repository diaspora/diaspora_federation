module DiasporaFederation
  # This module provides the namespace for the various classes implementing
  # WebFinger and other protocols used for metadata discovery on remote servers
  # in the Diaspora* network.
  module Discovery
  end
end

require "diaspora_federation/discovery/exceptions"
require "diaspora_federation/discovery/xrd_document"
require "diaspora_federation/discovery/host_meta"
require "diaspora_federation/discovery/web_finger"
require "diaspora_federation/discovery/h_card"
