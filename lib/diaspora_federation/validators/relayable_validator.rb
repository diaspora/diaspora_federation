module DiasporaFederation
  module Validators
    # This is included to validatros which validate entities which include {Entities::Relayable}
    module RelayableValidator
      # when this module is included in a Validator child it adds rules for relayable validation
      def self.included(model)
        model.class_eval do
          rule :parent_guid, :guid
        end
      end
    end
  end
end
