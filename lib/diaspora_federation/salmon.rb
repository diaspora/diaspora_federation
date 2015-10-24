module DiasporaFederation
  # This module contains a Diaspora*-specific implementation of parts of the
  # {http://www.salmon-protocol.org/ Salmon Protocol}.
  module Salmon
    # XML namespace url
    XMLNS = "https://joindiaspora.com/protocol"
  end
end

require "diaspora_federation/salmon/aes"
require "diaspora_federation/salmon/exceptions"
require "diaspora_federation/salmon/xml_payload"
require "diaspora_federation/salmon/magic_envelope"
require "diaspora_federation/salmon/slap"
require "diaspora_federation/salmon/encrypted_slap"