require "diaspora_federation/engine"
require "diaspora_federation/logging"

require "diaspora_federation/web_finger"

##
# diaspora* federation rails engine
module DiasporaFederation
  extend Logging

  class << self
    ##
    # the pod url
    #
    # Example:
    #   config.server_uri = URI("http://localhost:3000/")
    # or
    #   config.server_uri = AppConfig.pod_uri
    attr_accessor :server_uri

    ##
    # the class to use as person.
    #
    # Example:
    #   config.person_class = Person.to_s
    attr_accessor :person_class
    def person_class
      const_get(@person_class)
    end

    ##
    # configure the federation engine
    #
    #   DiasporaFederation.configure do |config|
    #     config.server_uri = "http://localhost:3000/"
    #   end
    def configure
      yield self
    end

    ##
    # validates if the engine is configured correctly
    #
    # called from after_initialize
    def validate_config
      raise ConfigurationError, "missing server_uri" unless @server_uri.respond_to? :host
      validate_class(@person_class, "person_class", %i(
        find_local_by_diaspora_handle
        webfinger_hash
      ))
      logger.info "successfully configured the federation engine"
    end

    private

    def validate_class(klass, name, methods)
      raise ConfigurationError, "missing #{name}" unless klass
      entity = const_get(klass)

      return logger.warn "table for #{entity} doesn't exist, skip validation" unless entity.table_exists?

      methods.each {|method| entity_respond_to?(entity, method) }
    end

    def entity_respond_to?(entity, method)
      valid = entity.respond_to?(method) || entity.column_names.include?(method.to_s) || entity.method_defined?(method)
      raise ConfigurationError, "the configured class #{entity} for #{name} doesn't respond to #{method}" unless valid
    end
  end

  # raised, if the engine is not configured correctly
  class ConfigurationError < RuntimeError
  end
end
