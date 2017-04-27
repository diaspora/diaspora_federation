module DiasporaFederation
  module Discovery
    # The WebFinger document used for diaspora* user discovery is based on an
    # {http://tools.ietf.org/html/draft-jones-appsawg-webfinger older draft of the specification}.
    #
    # In the meantime an actual RFC draft has been in development, which should
    # serve as a base for all future changes of this implementation.
    #
    # @example Creating a WebFinger document from a person hash
    #   wf = WebFinger.new(
    #     acct_uri:    "acct:user@server.example",
    #     alias_url:   "https://server.example/people/0123456789abcdef",
    #     hcard_url:   "https://server.example/hcard/users/user",
    #     seed_url:    "https://server.example/",
    #     profile_url: "https://server.example/u/user",
    #     atom_url:    "https://server.example/public/user.atom",
    #     salmon_url:  "https://server.example/receive/users/0123456789abcdef"
    #   )
    #   xml_string = wf.to_xml
    #
    # @example Creating a WebFinger instance from an xml document
    #   wf = WebFinger.from_xml(xml_string)
    #   ...
    #   hcard_url = wf.hcard_url
    #   ...
    #
    # @see http://tools.ietf.org/html/draft-jones-appsawg-webfinger "WebFinger" -
    #   current draft
    # @see http://www.iana.org/assignments/link-relations/link-relations.xhtml
    #   official list of IANA link relations
    class WebFinger < Entity
      # @!attribute [r] acct_uri
      #   The Subject element should contain the webfinger address that was asked
      #   for. If it does not, then this webfinger profile MUST be ignored.
      #   @return [String]
      property :acct_uri, :string

      # @!attribute [r] alias_url
      #   @note could be nil
      #   @return [String] link to the users profile
      property :alias_url, :string, default: nil

      # @!attribute [r] hcard_url
      #   @return [String] link to the +hCard+
      property :hcard_url, :string

      # @!attribute [r] seed_url
      #   @return [String] link to the pod
      property :seed_url, :string

      # @!attribute [r] profile_url
      #   @return [String] link to the users profile
      property :profile_url, :string, default: nil

      # @!attribute [r] atom_url
      #   This atom feed is an Activity Stream of the user's public posts. diaspora*
      #   pods SHOULD publish an Activity Stream of public posts, but there is
      #   currently no requirement to be able to read Activity Streams.
      #   @see http://activitystrea.ms/ Activity Streams specification
      #
      #   Note that this feed MAY also be made available through the PubSubHubbub
      #   mechanism by supplying a <link rel="hub"> in the atom feed itself.
      #   @return [String] atom feed url
      property :atom_url, :string, default: nil

      # @!attribute [r] salmon_url
      #   @note could be nil
      #   @return [String] salmon endpoint url
      #   @see https://cdn.rawgit.com/salmon-protocol/salmon-protocol/master/draft-panzer-salmon-00.html#SMLR
      #     Panzer draft for Salmon, paragraph 3.3
      property :salmon_url, :string, default: nil

      # @!attribute [r] subscribe_url
      #   This url is used to find another user on the home-pod of the user in the webfinger.
      property :subscribe_url, :string, default: nil

      # +hcard_url+ link relation
      REL_HCARD = "http://microformats.org/profile/hcard".freeze

      # +seed_url+ link relation
      REL_SEED = "http://joindiaspora.com/seed_location".freeze

      # +profile_url+ link relation.
      # @note This might just as well be an +Alias+ instead of a +Link+.
      REL_PROFILE = "http://webfinger.net/rel/profile-page".freeze

      # +atom_url+ link relation
      REL_ATOM = "http://schemas.google.com/g/2010#updates-from".freeze

      # +salmon_url+ link relation
      REL_SALMON = "salmon".freeze

      # +subscribe_url+ link relation
      REL_SUBSCRIBE = "http://ostatus.org/schema/1.0/subscribe".freeze

      # Creates the XML string from the current WebFinger instance
      # @return [String] XML string
      def to_xml
        doc = XrdDocument.new
        doc.subject = acct_uri
        doc.aliases << alias_url

        add_links_to(doc)

        doc.to_xml
      end

      # Creates a WebFinger instance from the given XML string
      # @param [String] webfinger_xml WebFinger XML string
      # @return [WebFinger] WebFinger instance
      # @raise [InvalidData] if the given XML string is invalid or incomplete
      def self.from_xml(webfinger_xml)
        data = parse_xml_and_validate(webfinger_xml)

        links = data[:links]

        new(
          acct_uri:      data[:subject],
          alias_url:     parse_alias(data[:aliases]),
          hcard_url:     parse_link(links, REL_HCARD),
          seed_url:      parse_link(links, REL_SEED),
          profile_url:   parse_link(links, REL_PROFILE),
          atom_url:      parse_link(links, REL_ATOM),
          salmon_url:    parse_link(links, REL_SALMON),

          subscribe_url: parse_link_template(links, REL_SUBSCRIBE)
        )
      end

      # @return [String] string representation of this object
      def to_s
        "WebFinger:#{acct_uri}"
      end

      private

      # Parses the XML string to a Hash and does some rudimentary checking on
      # the data Hash.
      # @param [String] webfinger_xml WebFinger XML string
      # @return [Hash] data XML data
      # @raise [InvalidData] if the given XML string is invalid or incomplete
      private_class_method def self.parse_xml_and_validate(webfinger_xml)
        XrdDocument.xml_data(webfinger_xml).tap do |data|
          valid = data.key?(:subject) && data.key?(:links)
          raise InvalidData, "webfinger xml is incomplete" unless valid
        end
      end

      def add_links_to(doc)
        doc.links << {rel: REL_HCARD, type: "text/html", href: hcard_url}
        doc.links << {rel: REL_SEED, type: "text/html", href: seed_url}

        add_optional_links_to(doc)
      end

      def add_optional_links_to(doc)
        doc.links << {rel: REL_PROFILE, type: "text/html", href: profile_url} if profile_url
        doc.links << {rel: REL_ATOM, type: "application/atom+xml", href: atom_url} if atom_url
        doc.links << {rel: REL_SALMON, href: salmon_url} if salmon_url

        doc.links << {rel: REL_SUBSCRIBE, template: subscribe_url} if subscribe_url
      end

      private_class_method def self.find_link(links, rel)
        links.find {|l| l[:rel] == rel }
      end

      private_class_method def self.parse_link(links, rel)
        element = find_link(links, rel)
        element ? element[:href] : nil
      end

      private_class_method def self.parse_link_template(links, rel)
        element = find_link(links, rel)
        element ? element[:template] : nil
      end

      # This method is used to parse the alias_url from the XML.
      # * redmatrix has sometimes no alias, return nil
      # * old pods had quotes around the alias url, this can be removed later
      # * friendica has two aliases and the first is with "acct:": return only an URL starting with http (or https)
      private_class_method def self.parse_alias(aliases)
        return nil unless aliases
        aliases.find {|a| a.start_with?("http") }
      end
    end
  end
end
