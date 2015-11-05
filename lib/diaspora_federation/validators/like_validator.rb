module DiasporaFederation
  module Validators
    class LikeValidator < Validation::Validator
      include Validation

      rule :guid, :guid

      rule :parent_guid, :guid

      rule :parent_author_signature, :not_empty

      rule :author_signature, :not_empty

      rule :diaspora_id, %i(not_empty diaspora_id)
    end
  end
end
