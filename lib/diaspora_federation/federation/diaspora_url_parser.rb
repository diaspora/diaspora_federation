module DiasporaFederation
  module Federation
    # This module is for parsing and fetching linked entities.
    module DiasporaUrlParser
      include Logging

      # Regex to find diaspora:// URLs
      DIASPORA_URL_REGEX = %r{
        diaspora://
        (#{Validation::Rule::DiasporaId::DIASPORA_ID_REGEX})/
        (#{Entity::ENTITY_NAME_REGEX})/
        (#{Validation::Rule::Guid::VALID_CHARS})
      }ux

      # Parses all diaspora:// URLs from the text and fetches the entities from
      # the remote server if needed.
      # @param [String] sender the diaspora* ID of the sender of the entity
      # @param [String] text text with diaspora:// URLs to fetch
      def self.fetch_linked_entities(text)
        text.scan(DIASPORA_URL_REGEX).each do |author, type, guid|
          fetch_entity(author, type, guid)
        end
      end

      private_class_method def self.fetch_entity(author, type, guid)
        class_name = Entity.entity_class(type).to_s.rpartition("::").last
        return if DiasporaFederation.callbacks.trigger(:fetch_related_entity, class_name, guid)
        Fetcher.fetch_public(author, type, guid)
      rescue => e # rubocop:disable Lint/RescueWithoutErrorClass
        logger.error "Failed to fetch linked entity #{type}:#{guid}: #{e.class}: #{e.message}"
      end
    end
  end
end
