module DiasporaFederation
  module Discovery
    # Raised, if the XML structure is invalid
    class InvalidDocument < RuntimeError
    end

    # Raised, if something is wrong with the webfinger data
    #
    # * if the +webfinger_url+ is missing or malformed in {HostMeta.from_base_url} or {HostMeta.from_xml}
    # * if the parsed XML from {WebFinger.from_xml} is incomplete
    # * if the html passed to {HCard.from_html} in some way is malformed, invalid or incomplete.
    class InvalidData < RuntimeError
    end

    # Raised, if there is an error while discover a new person
    class DiscoveryError < RuntimeError
    end
  end
end
