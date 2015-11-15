module DiasporaFederation
  module Entities
    module Relayable
      def self.included(model)
        model.class_eval do
          property :parent_guid
          property :parent_author_signature
          property :author_signature
        end
      end
    end
  end
end
