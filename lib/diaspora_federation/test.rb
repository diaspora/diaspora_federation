require "diaspora_federation/test/factories"

module DiasporaFederation
  # This module incapsulates helper functions maybe wanted by a testsuite of a diaspora_federation gem user application
  module Test
    # Sort hash according to an entity class's property sequence.
    # This is used for rspec tests in order to generate correct input hash to
    # compare results with.
    #
    # @param [Hash] data input hash for sorting
    # @param [Entity.Class] klass entity type to sort according to
    # @return [Hash] sorted hash
    def self.sort_hash(data, klass)
      klass.class_props.map { |prop|
        [prop[:name], data[prop[:name]]] unless data[prop[:name]].nil?
      }.compact.to_h
    end

    # Generates attributes for entity constructor with correct signatures in it
    #
    # @param [Symbol] entity_type type to generate attributes for
    # @return [Hash] hash with correct signatures
    def self.relayable_attributes_with_signatures(entity_type)
      DiasporaFederation::Entities::Relayable.update_signatures!(
        sort_hash(FactoryGirl.attributes_for(entity_type), FactoryGirl.factory_by_name(entity_type).build_class)
      )
    end
  end
end
