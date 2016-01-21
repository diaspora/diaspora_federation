require "diaspora_federation/test/factories"

module DiasporaFederation
  # This module encapsulates helper functions maybe wanted by a testsuite of a diaspora_federation gem user application
  module Test
    # Generates attributes for entity constructor with correct signatures in it
    #
    # @param [Symbol] factory_name the factory to generate attributes for (normally entity name)
    # @return [Hash] hash with correct signatures
    def self.attributes_with_signatures(factory_name)
      FactoryGirl.build(factory_name).to_signed_h
    end
  end
end
