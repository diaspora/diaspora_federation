module DiasporaFederation
  module WebFinger
    ##
    # Raised, if the XML structure is invalid
    class InvalidDocument < RuntimeError
    end

    ##
    # Raised, if something is wrong with the webfinger data
    #
    # * if the +webfinger_url+ is missing or malformed in {HostMeta.from_base_url} or {HostMeta.from_xml}
    # * if the +data+ given to {WebFinger.from_account} is an invalid type or doesn't contain all required entries
    # * if the parsed XML from {WebFinger.from_xml} is incomplete
    class InvalidData < RuntimeError
    end
  end
end
