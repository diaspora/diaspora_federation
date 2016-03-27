module DiasporaFederation
  module Validators
    # This validates a {Entities::RelatedEntity}
    class RelatedEntityValidator < Validation::Validator
      include Validation

      rule :author, %i(not_empty diaspora_id)
      rule :local, :boolean
      rule :public, :boolean
    end
  end
end
