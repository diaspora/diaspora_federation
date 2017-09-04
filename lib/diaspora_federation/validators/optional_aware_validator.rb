module DiasporaFederation
  module Validators
    # Abstract validator which only validates optional fields when they are not nil.
    class OptionalAwareValidator < Validation::Validator
      def rules
        super.reject do |field, rules|
          @obj.public_send(field).nil? &&
            !rules.map(&:class).include?(Validation::Rule::NotNil) &&
            optional_props.include?(field)
        end
      end

      private

      def optional_props
        entity_name = self.class.name.split("::").last.sub("Validator", "")
        return [] unless Entities.const_defined?(entity_name)

        Entities.const_get(entity_name).optional_props
      end
    end
  end
end
