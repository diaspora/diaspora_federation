module DiasporaFederation
  module Federation
    # This module is for fetching entities from other pods.
    module Fetcher
      # Fetches a public entity from a remote pod
      # @param [String] author the diaspora* ID of the author of the entity
      # @param [Symbol, String] entity_type snake_case version of the entity class
      # @param [String] guid guid of the entity to fetch
      def self.fetch_public(author, entity_type, guid)
        url = DiasporaFederation.callbacks.trigger(
          :fetch_person_url_to, author, "/fetch/#{entity_name(entity_type)}/#{guid}"
        )
        response = HttpClient.get(url)
        raise "Failed to fetch #{url}: #{response.status}" unless response.success?

        magic_env_xml = Nokogiri::XML::Document.parse(response.body).root
        magic_env = Salmon::MagicEnvelope.unenvelop(magic_env_xml)
        Receiver::Public.new(magic_env).receive
      rescue => e
        raise NotFetchable, "Failed to fetch #{entity_type}:#{guid} from #{author}: #{e.class}: #{e.message}"
      end

      private_class_method def self.entity_name(class_name)
        return class_name if class_name =~ /\A[a-z]*(_[a-z]*)*\z/

        raise DiasporaFederation::Entity::UnknownEntity, class_name unless Entities.const_defined?(class_name)

        class_name.gsub(/(.)([A-Z])/, '\1_\2').downcase
      end

      # Raised, if the entity is not fetchable
      class NotFetchable < RuntimeError
      end
    end
  end
end
