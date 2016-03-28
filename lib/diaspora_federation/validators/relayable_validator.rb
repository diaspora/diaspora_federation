module DiasporaFederation
  module Validators
    # This is included to validatros which validate entities which include {Entities::Relayable}
    module RelayableValidator
      # when this module is included in a Validator child it adds rules for relayable validation
      # @param [Validation::Validator] validator the validator in which it is included
      def self.included(validator)
        validator.class_eval do
          rule :author, %i(not_empty diaspora_id)
          rule :guid, :guid
          rule :parent_guid, :guid
          rule :parent, :not_nil
        end
      end
    end
  end
end
