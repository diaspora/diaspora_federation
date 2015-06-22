module DiasporaFederation
  ##
  # This module provides the namespace for the various classes implementing
  # WebFinger and other protocols used for metadata discovery on remote servers
  # in the Diaspora* network.
  module WebFinger
  end
end

require "diaspora_federation/web_finger/exceptions"
require "diaspora_federation/web_finger/xrd_document"
require "diaspora_federation/web_finger/host_meta"
require "diaspora_federation/web_finger/web_finger"
require "diaspora_federation/web_finger/h_card"
