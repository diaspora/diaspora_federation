require "diaspora_federation/test/factories"

module DiasporaFederation
  # This module encapsulates helper functions maybe wanted by a testsuite of a diaspora_federation gem user application
  module Test
    # Sort hash according to an entity class's property sequence.
    # This is used for rspec tests in order to generate correct input hash to
    # compare results with.
    #
    # @param [Hash] data input hash for sorting
    # @param [Entity.Class] klass entity type to sort according to
    # @return [Hash] sorted hash
    def self.sort_hash(data, klass)
      Hash[klass.class_props.map { |prop|
        [prop[:name], data[prop[:name]]] unless data[prop[:name]].nil?
      }.compact]
    end

    # Generates attributes for entity constructor with correct signatures in it
    #
    # @param [Symbol] factory_name the factory to generate attributes for (normally entity name)
    # @return [Hash] hash with correct signatures
    def self.relayable_attributes_with_signatures(factory_name)
      klass = FactoryGirl.factory_by_name(factory_name).build_class
      sort_hash(FactoryGirl.attributes_for(factory_name), klass).tap do |data|
        DiasporaFederation::Entities::Relayable.update_signatures!(data)
      end
    end
  end
end
