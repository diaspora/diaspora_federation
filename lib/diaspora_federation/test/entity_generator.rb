# frozen_string_literal: true

module DiasporaFederation
  module Test
    # Generator to instantiate entities
    class EntityGenerator < Fabrication::Generator::Base
      def self.supports?(klass)
        klass.ancestors.include?(DiasporaFederation::Entity)
      end

      def build_instance
        self._instance = _klass.new(_attributes)
      end

      def to_hash(attributes=[], _callbacks=[])
        process_attributes(attributes)
        _attributes.each_with_object({}) do |(name, value), hash|
          hash[name.to_sym] = value
        end
      end
    end

    Fabrication.configure do |config|
      config.generators << EntityGenerator
    end
  end
end
