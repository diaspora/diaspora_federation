# frozen_string_literal: true

module DiasporaFederation
  module Discovery
    # Generates and parses Host Meta documents.
    #
    # This is a minimal implementation of the standard, only to the degree of what
    # is used for the purposes of the diaspora* protocol. (e.g. WebFinger)
    #
    # @example Creating a Host Meta document
    #   doc = HostMeta.from_base_url("https://pod.example.tld/")
    #   doc.to_xml
    #
    # @example Parsing a Host Meta document
    #   doc = HostMeta.from_xml(xml_string)
    #   webfinger_tpl = doc.webfinger_template_url
    #
    # @see http://tools.ietf.org/html/rfc6415 RFC 6415: "Web Host Metadata"
    # @see XrdDocument
    class HostMeta
      private_class_method :new

      # Creates a new host-meta instance
      # @param [String] webfinger_url the webfinger-url
      def initialize(webfinger_url)
        @webfinger_url = webfinger_url
      end

      # URL fragment to append to the base URL
      WEBFINGER_SUFFIX = "/.well-known/webfinger.xml?resource={uri}"

      # Returns the WebFinger URL that was used to build this instance (either from
      # xml or by giving a base URL).
      # @return [String] WebFinger template URL
      def webfinger_template_url
        @webfinger_url
      end

      # Produces the XML string for the Host Meta instance with a +Link+ element
      # containing the +webfinger_url+.
      # @return [String] XML string
      def to_xml
        doc = XrdDocument.new
        doc.links << {rel:      "lrdd",
                      type:     "application/xrd+xml",
                      template: @webfinger_url}
        doc.to_xml
      end

      # Builds a new HostMeta instance and constructs the WebFinger URL from the
      # given base URL by appending HostMeta::WEBFINGER_SUFFIX.
      # @param [String, URL] base_url the base-url for the webfinger-url
      # @return [HostMeta]
      # @raise [InvalidData] if the webfinger url is malformed
      def self.from_base_url(base_url)
        webfinger_url = "#{base_url.to_s.chomp('/')}#{WEBFINGER_SUFFIX}"
        raise InvalidData, "invalid webfinger url: #{webfinger_url}" unless webfinger_url_valid?(webfinger_url)

        new(webfinger_url)
      end

      # Reads the given Host Meta XML document string and populates the
      # +webfinger_url+.
      # @param [String] hostmeta_xml Host Meta XML string
      # @raise [InvalidData] if the xml or the webfinger url is malformed
      def self.from_xml(hostmeta_xml)
        data = XrdDocument.xml_data(hostmeta_xml)
        raise InvalidData, "received an invalid xml" unless data.key?(:links)

        webfinger_url = webfinger_url_from_xrd(data)
        raise InvalidData, "invalid webfinger url: #{webfinger_url}" unless webfinger_url_valid?(webfinger_url)

        new(webfinger_url)
      end

      # Applies some basic sanity-checking to the given URL
      # @param [String] url validation subject
      # @return [Boolean] validation result
      private_class_method def self.webfinger_url_valid?(url)
        !url.nil? && url.instance_of?(String) && url =~ %r{\Ahttps?:\/\/.*\/.*\{uri\}.*}i
      end

      # Gets the webfinger url from an XRD data structure
      # @param [Hash] data extracted data
      # @return [String] webfinger url
      private_class_method def self.webfinger_url_from_xrd(data)
        link = data[:links].find {|l| l[:rel] == "lrdd" }
        return link[:template] unless link.nil?
      end
    end
  end
end
