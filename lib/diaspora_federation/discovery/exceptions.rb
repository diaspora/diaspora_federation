# frozen_string_literal: true

module DiasporaFederation
  module Discovery
    # Raised, if there is an error while discover a new person
    class DiscoveryError < RuntimeError
    end

    # Raised, if the XML structure is invalid
    class InvalidDocument < DiscoveryError
    end

    # Raised, if something is wrong with the webfinger data
    #
    # * if the +webfinger_url+ is missing or malformed in {HostMeta.from_base_url} or {HostMeta.from_xml}
    # * if the parsed XML from {WebFinger.from_xml} is incomplete
    # * if the html passed to {HCard.from_html} in some way is malformed, invalid or incomplete.
    class InvalidData < DiscoveryError
    end
  end
end
