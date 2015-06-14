require "diaspora_federation/engine"

##
# diaspora* federation rails engine
module DiasporaFederation
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
    #   config.person_class = Person.class.to_s
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
  end
end
