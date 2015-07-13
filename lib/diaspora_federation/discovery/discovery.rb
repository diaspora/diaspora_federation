module DiasporaFederation
  module Discovery
    # This class contains the logic to fetch all data for the given handle
    class Discovery
      include DiasporaFederation::Logging

      # @return [String] the handle of the account
      attr_reader :handle

      # @param [String] account the diaspora handle to discover
      def initialize(account)
        @handle = clean_handle(account)
      end

      # fetch all metadata for the account
      def fetch
        logger.info "Fetch data for #{handle}"

        unless handle == clean_handle(webfinger.acct_uri)
          raise DiscoveryError, "Handle does not match: Wanted #{handle} but got #{clean_handle(webfinger.acct_uri)}"
        end

        discovery_data_hash
      end

      private

      def clean_handle(account)
        account.strip.sub("acct:", "").to_s.downcase
      end

      def get(url, http_fallback=false)
        logger.info "Fetching #{url} for #{handle}"
        response = Fetcher.get(url)
        raise "Failed to fetch #{url}: #{response.status}" unless response.success?
        response.body
      rescue => e
        if http_fallback && url.start_with?("https://")
          logger.warn "Retry with http: #{url} for #{handle}: #{e.class}: #{e.message}"
          url.sub!("https://", "http://")
          retry
        else
          raise DiscoveryError, "Failed to fetch #{url} for #{handle}: #{e.class}: #{e.message}"
        end
      end

      def host_meta_url
        domain = handle.split("@")[1]
        "https://#{domain}/.well-known/host-meta"
      end

      def legacy_webfinger_url_from_host_meta
        # this tries the xrd url with https first, then falls back to http
        host_meta = HostMeta.from_xml get(host_meta_url, true)
        host_meta.webfinger_template_url.gsub("{uri}", "acct:#{handle}")
      end

      def webfinger
        @webfinger ||= WebFinger.from_xml get(legacy_webfinger_url_from_host_meta)
      end

      def hcard
        @hcard ||= HCard.from_html get(webfinger.hcard_url)
      end

      def discovery_data_hash
        hcard_hash = hcard.to_h.expect(:guid, :serialized_public_key)
        hcard_hash.merge(
          guid:            hcard.guid || webfinger.guid,
          public_key:      hcard.public_key || webfinger.public_key,
          diaspora_handle: handle,
          seed_url:        webfinger.seed_url
        )
      end
    end
  end
end
