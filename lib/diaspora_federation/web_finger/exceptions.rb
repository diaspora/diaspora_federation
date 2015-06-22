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
    # * if the +data+ given to {WebFinger.from_person} is an invalid type or doesn't contain all required entries
    # * if the parsed XML from {WebFinger.from_xml} is incomplete
    # * if the params passed to {HCard.from_account} or {HCard.from_html}
    #   are in some way malformed, invalid or incomplete.
    class InvalidData < RuntimeError
    end
  end
end
