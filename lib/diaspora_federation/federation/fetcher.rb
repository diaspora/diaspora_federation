module DiasporaFederation
  module Federation
    # this module is for fetching entities from other pods
    module Fetcher
      # fetches a public entity from a remote pod
      # @param [String] author the diaspora ID of the author of the entity
      # @param [Symbol, String] entity_type snake_case version of the entity class
      # @param [String] guid guid of the entity to fetch
      def self.fetch_public(author, entity_type, guid)
        url = DiasporaFederation.callbacks.trigger(:fetch_person_url_to, author, "/fetch/#{entity_type}/#{guid}")
        response = HttpClient.get(url)
        raise "Failed to fetch #{url}: #{response.status}" unless response.success?

        magic_env_xml = Nokogiri::XML::Document.parse(response.body).root
        magic_env = Salmon::MagicEnvelope.unenvelop(magic_env_xml)
        DiasporaFederation.callbacks.trigger(:receive_entity, magic_env.payload)
      rescue => e
        raise NotFetchable, "Failed to fetch #{entity_type}:#{guid} from #{author}: #{e.class}: #{e.message}"
      end

      # Raised, if the entity is not fetchable
      class NotFetchable < RuntimeError
      end
    end
  end
end
