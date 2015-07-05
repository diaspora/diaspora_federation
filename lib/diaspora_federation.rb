require "diaspora_federation/logging"

require "diaspora_federation/callbacks"
require "diaspora_federation/web_finger"

# diaspora* federation library
module DiasporaFederation
  extend Logging

  @callbacks = Callbacks.new %i(
    person_webfinger_fetch
    person_hcard_fetch
  )

  class << self
    attr_reader :callbacks

    # the pod url
    #
    # @example with uri
    #   config.server_uri = URI("http://localhost:3000/")
    # @example with configured pod_uri
    #   config.server_uri = AppConfig.pod_uri
    attr_accessor :server_uri

    # configure the federation library
    #
    # @example
    #   DiasporaFederation.configure do |config|
    #     config.server_uri = URI("http://localhost:3000/")
    #
    #     config.define_callbacks do
    #       # callback configuration
    #     end
    #   end
    def configure
      yield self
    end

    def define_callbacks(&block)
      @callbacks.instance_eval(&block)
    end

    # validates if the engine is configured correctly
    #
    # called from after_initialize
    # @raise [ConfigurationError] if the configuration is incomplete or invalid
    def validate_config
      configuration_error "Missing server_uri" unless @server_uri.respond_to? :host
      unless @callbacks.definition_complete?
        configuration_error "Missing handlers for #{@callbacks.missing_handlers.join(', ')}"
      end
      logger.info "successfully configured the federation library"
    end

    private

    def configuration_error(message)
      logger.fatal("diaspora federation configuration error: #{message}")
      raise ConfigurationError, message
    end
  end

  # raised, if the engine is not configured correctly
  class ConfigurationError < RuntimeError
  end
end
