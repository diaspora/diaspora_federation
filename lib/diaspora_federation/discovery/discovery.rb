module DiasporaFederation
  module Discovery
    # This class contains the logic to fetch all data for the given diaspora* ID.
    class Discovery
      include DiasporaFederation::Logging

      # @return [String] the diaspora* ID of the account
      attr_reader :diaspora_id

      # Creates a discovery class for the diaspora* ID
      # @param [String] diaspora_id the diaspora* ID to discover
      def initialize(diaspora_id)
        @diaspora_id = clean_diaspora_id(diaspora_id)
      end

      # Fetches all metadata for the account and saves it via callback
      # @return [Person]
      def fetch_and_save
        logger.info "Fetch data for #{diaspora_id}"

        validate_diaspora_id

        DiasporaFederation.callbacks.trigger(:save_person_after_webfinger, person)
        logger.info "successfully webfingered #{diaspora_id}"
        person
      end

      private

      def validate_diaspora_id
        # Validates if the diaspora* ID matches the diaspora* ID in the webfinger response
        return if diaspora_id == clean_diaspora_id(webfinger.acct_uri)
        raise DiscoveryError, "diaspora* ID does not match: Wanted #{diaspora_id} but got" \
                              " #{clean_diaspora_id(webfinger.acct_uri)}"
      end

      def clean_diaspora_id(diaspora_id)
        diaspora_id.strip.sub("acct:", "").to_s.downcase
      end

      def get(url, http_fallback=false)
        logger.info "Fetching #{url} for #{diaspora_id}"
        response = HttpClient.get(url)
        raise "Failed to fetch #{url}: #{response.status}" unless response.success?
        response.body
      rescue => e
        if http_fallback && url.start_with?("https://")
          logger.warn "Retry with http: #{url} for #{diaspora_id}: #{e.class}: #{e.message}"
          url.sub!("https://", "http://")
          retry
        else
          raise DiscoveryError, "Failed to fetch #{url} for #{diaspora_id}: #{e.class}: #{e.message}"
        end
      end

      def host_meta_url
        domain = diaspora_id.split("@")[1]
        "https://#{domain}/.well-known/host-meta"
      end

      def legacy_webfinger_url_from_host_meta
        # This tries the xrd url with https first, then falls back to http.
        host_meta = HostMeta.from_xml get(host_meta_url, true)
        host_meta.webfinger_template_url.gsub("{uri}", "acct:#{diaspora_id}")
      end

      def webfinger
        @webfinger ||= WebFinger.from_xml get(legacy_webfinger_url_from_host_meta)
      end

      def hcard
        @hcard ||= HCard.from_html get(webfinger.hcard_url)
      end

      def person
        @person ||= Entities::Person.new(
          guid:         hcard.guid || webfinger.guid,
          diaspora_id:  diaspora_id,
          url:          webfinger.seed_url,
          exported_key: hcard.public_key || webfinger.public_key,
          profile:      profile
        )
      end

      def profile
        Entities::Profile.new(
          diaspora_id:      diaspora_id,
          first_name:       hcard.first_name,
          last_name:        hcard.last_name,
          image_url:        hcard.photo_large_url,
          image_url_medium: hcard.photo_medium_url,
          image_url_small:  hcard.photo_small_url,
          searchable:       hcard.searchable
        )
      end
    end
  end
end
