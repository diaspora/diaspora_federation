require "diaspora_federation/test/factories"

module DiasporaFederation
  module Test
    # Sort hash according to an entity class's property sequence.
    # This is used for rspec tests in order to generate correct input hash to
    # compare results with.
    #
    def self.sort_hash(data, klass)
      klass.class_props.map { |prop|
        [prop[:name], data[prop[:name]]] unless data[prop[:name]].nil?
      }.compact.to_h
    end

    def self.relayable_attributes_with_signatures(entity_type)
      DiasporaFederation::Entities::Relayable.update_signatures!(
        sort_hash(FactoryGirl.attributes_for(entity_type), FactoryGirl.factory_by_name(entity_type).build_class)
      )
    end
  end
end
