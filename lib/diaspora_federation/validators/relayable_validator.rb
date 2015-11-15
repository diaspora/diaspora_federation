module DiasporaFederation
  module Validators
    module RelayableValidator
      def self.included(model)
        model.class_eval do
          rule :parent_guid, :guid
        end
      end
    end
  end
end
