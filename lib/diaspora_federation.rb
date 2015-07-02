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
    # @example with uri
    #   config.server_uri = URI("http://localhost:3000/")
    # @example with configured pod_uri
    #   config.server_uri = AppConfig.pod_uri
    attr_accessor :server_uri

    ##
    # the class to use as +Person+
    #
    # @example
    #   config.person_class = Person
    #
    # This class must have the following class methods:::
    #
    #   +find_local_by_diaspora_handle+:
    #   This should return a +Person+, which is on this pod and the account is not closed.
    #
    #   +find_local_by_guid+:
    #   This should return a +Person+, which is on this pod and the account is not closed.
    #
    # This class must have the following instance methods or attributes:::
    #
    #   +diaspora_handle+: the diaspora handle
    #     "user@server.example"
    #
    #   +nickname+: the username on the pod
    #     "user"
    #
    #   +guid+: the guid
    #     "0123456789abcdef"
    #
    #   +public_key+: the public key of the person (DER-encoded PKCS#1 key)
    #     "-----BEGIN PUBLIC KEY-----
    #     ABCDEF==
    #     -----END PUBLIC KEY-----"
    #
    #   +searchable+: if the person is searchable by name
    #     true
    #
    #   +alias_url+: alias url to the profile
    #     "https://server.example/people/0123456789abcdef"
    #
    #   +hcard_url+: url to the hcard
    #     "https://server.example/hcard/users/0123456789abcdef"
    #
    #   +seed_url+: pod url
    #     "https://server.example/"
    #
    #   +profile_url+: url to the profile
    #     "https://server.example/u/user"
    #
    #   +atom_url+: url to the atom rss feed
    #     "https://server.example/public/user.atom"
    #
    #   +salmon_url+: private receive url for salmon
    #     "https://server.example/receive/users/0123456789abcdef"
    #
    #   +photo_large_url+: large photo
    #     "https://server.example/uploads/l.jpg"
    #
    #   +photo_medium_url+: medium photo
    #     "https://server.example/uploads/m.jpg"
    #
    #   +photo_small_url+: small photo
    #     "https://server.example/uploads/s.jpg"
    #
    #   +full_name+: full name
    #     "User Name"
    #
    #   +first_name+: first name
    #     "User"
    #
    #   +last_name+: last name
    #     "Name"
    attr_accessor :person_class

    def person_class=(klass)
      @person_class = klass.nil? ? nil : klass.to_s
    end

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
    # @raise [ConfigurationError] if the configuration is incomplete or invalid
    def validate_config
      configuration_error "missing server_uri" unless @server_uri.respond_to? :host
      validate_class(@person_class, "person_class", %i(
        find_local_by_diaspora_handle find_local_by_guid
        diaspora_handle nickname guid public_key searchable
        alias_url hcard_url seed_url profile_url atom_url salmon_url
        photo_large_url photo_medium_url photo_small_url
        full_name first_name last_name
      ))
      logger.info "successfully configured the federation engine"
    end

    private

    def validate_class(klass, name, methods)
      configuration_error "missing #{name}" unless klass
      entity = const_get(klass)

      return logger.warn "table for #{entity} doesn't exist, skip validation" unless entity.table_exists?

      methods.each {|method| entity_respond_to?(entity, name, method) }
    end

    def entity_respond_to?(entity, name, method)
      valid = entity.respond_to?(method) || entity.column_names.include?(method.to_s) || entity.method_defined?(method)
      configuration_error "the configured class #{entity} for #{name} doesn't respond to #{method}" unless valid
    end

    def configuration_error(message)
      logger.fatal("diaspora federation configuration error: #{message}")
      raise ConfigurationError, message
    end
  end

  # raised, if the engine is not configured correctly
  class ConfigurationError < RuntimeError
  end
end
