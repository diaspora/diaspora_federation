module DiasporaFederation
  module Validators
    class RetractionValidator < Validation::Validator
      include Validation

      rule :post_guid, :guid

      rule :diaspora_id, %i(not_empty diaspora_id)

      rule :type, :not_empty
    end
  end
end
