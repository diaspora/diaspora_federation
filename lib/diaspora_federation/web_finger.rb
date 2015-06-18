module DiasporaFederation
  ##
  # This module provides the namespace for the various classes implementing
  # WebFinger and other protocols used for metadata discovery on remote servers
  # in the Diaspora* network.
  module WebFinger
  end
end

require "diaspora_federation/webfinger/xrd_document"
require "diaspora_federation/webfinger/host_meta"
